#!/usr/bin/env python3
import curses
import os
import re
import subprocess
import sys
import threading
import time

networks = {} # key: (ssid, band) -> dict
saved_conns = set()
active_conn = None
active_ip = ""
wifi_dev = ""
lock = threading.Lock()
running = True
status_msg = "Scanning for Wi-Fi networks..."
trigger_rescan_event = threading.Event()

def get_wifi_icons(signal, is_secured):
    if signal >= 75:
        return ("󰤪" if is_secured else "󰤨")
    elif signal >= 50:
        return ("󰤧" if is_secured else "󰤥")
    elif signal >= 25:
        return ("󰤤" if is_secured else "󰤢")
    else:
        return ("󰤡" if is_secured else "󰤟")

def get_wifi_device_and_ip():
    global wifi_dev, active_ip
    try:
        dev_out = subprocess.check_output(
            ["nmcli", "-t", "-f", "DEVICE,TYPE", "dev"],
            text=True, stderr=subprocess.DEVNULL
        )
        for line in dev_out.splitlines():
            if line.endswith(":wifi"):
                wifi_dev = line.split(":", 1)[0].strip()
                break
    except Exception:
        wifi_dev = ""

    if wifi_dev:
        try:
            ip_out = subprocess.check_output(
                ["nmcli", "-t", "-f", "IP4.ADDRESS", "dev", "show", wifi_dev],
                text=True, stderr=subprocess.DEVNULL
            )
            for line in ip_out.splitlines():
                if "IP4.ADDRESS" in line and ":" in line:
                    active_ip = line.split(":", 1)[1].strip()
                    return
        except Exception:
            pass
    active_ip = ""

def fetch_saved_connections():
    global saved_conns
    try:
        out = subprocess.check_output(
            ["nmcli", "-t", "-f", "NAME,TYPE", "con", "show"],
            text=True, stderr=subprocess.DEVNULL
        )
        saved = set()
        for line in out.splitlines():
            if line.endswith(":802-11-wireless"):
                name = line.rsplit(":802-11-wireless", 1)[0].strip()
                if name:
                    saved.add(name)
        with lock:
            saved_conns = saved
    except Exception:
        pass

def scan_worker():
    global running, active_conn
    while running:
        fetch_saved_connections()
        get_wifi_device_and_ip()

        # Query currently active connection name from NetworkManager
        nm_active_ssid = None
        try:
            act_out = subprocess.check_output(
                ["nmcli", "-t", "-f", "NAME,TYPE,DEVICE", "con", "show", "--active"],
                text=True, stderr=subprocess.DEVNULL
            )
            for line in act_out.splitlines():
                if ":802-11-wireless:" in line:
                    nm_active_ssid = line.split(":802-11-wireless:", 1)[0].strip()
                    break
        except Exception:
            pass

        try:
            subprocess.run(["nmcli", "dev", "wifi", "rescan"], capture_output=True, timeout=3)
        except Exception:
            pass

        try:
            out = subprocess.check_output(
                ["nmcli", "-t", "-f", "IN-USE,SIGNAL,SECURITY,FREQ,SSID", "dev", "wifi", "list", "--rescan", "no"],
                text=True, stderr=subprocess.DEVNULL, timeout=5
            )
            now = time.time()
            scan_results = {}
            found_active_key = None

            for line in out.splitlines():
                parts = line.split(":", 4)
                if len(parts) < 5:
                    continue
                in_use = parts[0].strip() == "*"
                try:
                    signal = int(parts[1].strip())
                except ValueError:
                    signal = 0
                security = parts[2].strip()
                freq_str = parts[3].strip().replace(" MHz", "")
                ssid = parts[4].strip()

                if not ssid or ssid == "--":
                    continue

                try:
                    freq_int = int(freq_str)
                    band = "5 GHz" if freq_int >= 4900 else "2.4 GHz"
                except ValueError:
                    band = "2.4 GHz"

                key = (ssid, band)
                is_secured = (security != "" and security != "--")

                if in_use:
                    found_active_key = key

                if key not in scan_results:
                    scan_results[key] = {
                        "ssid": ssid,
                        "band": band,
                        "signal": signal,
                        "security": security,
                        "is_secured": is_secured,
                        "in_use": in_use,
                        "updated": now
                    }
                else:
                    if in_use:
                        scan_results[key]["in_use"] = True
                    if signal > scan_results[key]["signal"]:
                        scan_results[key]["signal"] = signal
                    scan_results[key]["updated"] = now

            # If NetworkManager reports active ssid, ensure corresponding entry is marked in_use
            if nm_active_ssid:
                if found_active_key and found_active_key in scan_results:
                    scan_results[found_active_key]["in_use"] = True
                else:
                    matching = [k for k in scan_results if k[0] == nm_active_ssid]
                    if matching:
                        best_k = max(matching, key=lambda k: scan_results[k]["signal"])
                        scan_results[best_k]["in_use"] = True
                        found_active_key = best_k

            with lock:
                active_conn = found_active_key
                for k, v in scan_results.items():
                    networks[k] = v

                # Prune networks not seen for > 10s (unless connected or saved)
                expired = [
                    k for k, v in list(networks.items())
                    if not v["in_use"] and (k[0] not in saved_conns) and (now - v["updated"] > 10.0)
                ]
                for k in expired:
                    del networks[k]

        except Exception:
            pass

        trigger_rescan_event.wait(timeout=3.5)
        trigger_rescan_event.clear()

def connect_network(ssid, password=None):
    def _worker():
        global status_msg
        try:
            status_msg = f"Connecting to {ssid}..."
            subprocess.run(["notify-send", "-i", "network-wireless", "Wi-Fi", f"Connecting to {ssid}..."])
            
            with lock:
                is_saved = ssid in saved_conns

            if is_saved:
                cmd = ["nmcli", "con", "up", ssid]
            elif password:
                cmd = ["nmcli", "dev", "wifi", "connect", ssid, "password", password]
            else:
                cmd = ["nmcli", "dev", "wifi", "connect", ssid]

            res = subprocess.run(cmd, capture_output=True, text=True, timeout=20)
            if res.returncode == 0:
                status_msg = f"Connected to {ssid}!"
                subprocess.run(["notify-send", "-i", "network-wireless", "Wi-Fi", f"Connected: {ssid}"])
                fetch_saved_connections()
                get_wifi_device_and_ip()
                trigger_rescan_event.set()
            else:
                err = res.stderr.strip() or res.stdout.strip()
                status_msg = f"Failed: {err.splitlines()[-1] if err else 'Unknown error'}"
                subprocess.run(["notify-send", "-u", "critical", "-i", "network-wireless-offline", "Wi-Fi Error", status_msg])
        except subprocess.TimeoutExpired:
            status_msg = f"Timeout connecting to {ssid}"
        except Exception as e:
            status_msg = f"Error: {e}"

    threading.Thread(target=_worker, daemon=True).start()

def disconnect_active():
    def _worker():
        global status_msg
        try:
            status_msg = "Disconnecting Wi-Fi..."
            if wifi_dev:
                res = subprocess.run(["nmcli", "dev", "disconnect", wifi_dev], capture_output=True, text=True, timeout=5)
            else:
                res = subprocess.run(["nmcli", "radio", "wifi", "off"], capture_output=True, text=True, timeout=5)
                subprocess.run(["nmcli", "radio", "wifi", "on"], capture_output=True, text=True, timeout=5)

            status_msg = "Wi-Fi disconnected."
            subprocess.run(["notify-send", "-i", "network-wireless-disconnected", "Wi-Fi", "Disconnected"])
            trigger_rescan_event.set()
        except Exception as e:
            status_msg = f"Error disconnecting: {e}"

    threading.Thread(target=_worker, daemon=True).start()

def forget_network(ssid):
    def _worker():
        global status_msg
        try:
            status_msg = f"Forgetting network: {ssid}..."
            res = subprocess.run(["nmcli", "con", "delete", ssid], capture_output=True, text=True, timeout=5)
            if res.returncode == 0:
                status_msg = f"Removed saved network: {ssid}"
                subprocess.run(["notify-send", "-i", "edit-delete", "Wi-Fi", f"Removed network: {ssid}"])
                fetch_saved_connections()
                trigger_rescan_event.set()
            else:
                status_msg = f"Failed to remove {ssid}"
        except Exception as e:
            status_msg = f"Error: {e}"

    threading.Thread(target=_worker, daemon=True).start()

def prompt_password(stdscr, ssid):
    max_y, max_x = stdscr.getmaxyx()
    win_h = 7
    win_w = min(56, max_x - 4)
    win_y = max(1, (max_y - win_h) // 2)
    win_x = max(1, (max_x - win_w) // 2)

    win = curses.newwin(win_h, win_w, win_y, win_x)
    win.keypad(True)
    curses.curs_set(1)

    password = []
    while True:
        win.erase()
        win.box()
        win.attron(curses.color_pair(1) | curses.A_BOLD)
        title = f" Wi-Fi Security: {ssid[:22]} "
        win.addstr(0, max(1, (win_w - len(title)) // 2), title[:win_w-2])
        win.attroff(curses.color_pair(1) | curses.A_BOLD)

        win.addstr(2, 3, "Password:")
        
        masked = "*" * len(password)
        field_w = win_w - 18
        win.attron(curses.A_REVERSE)
        win.addstr(2, 13, f" {masked[-field_w:]:<{field_w}} ")
        win.attroff(curses.A_REVERSE)

        win.addstr(4, 3, "[Enter] Connect        [Esc] Cancel", curses.A_DIM)
        win.move(2, 14 + min(len(password), field_w - 1))
        win.refresh()

        ch = win.getch()
        if ch in (10, 13, curses.KEY_ENTER):
            break
        elif ch == 27:
            password = None
            break
        elif ch in (curses.KEY_BACKSPACE, 127, 8):
            if password:
                password.pop()
        elif 32 <= ch <= 126:
            password.append(chr(ch))

    curses.curs_set(0)
    del win
    stdscr.touchwin()
    stdscr.refresh()
    return "".join(password) if password is not None else None

def curses_main(stdscr):
    global running, status_msg
    curses.curs_set(0)
    stdscr.nodelay(True)
    stdscr.timeout(150)
    curses.mousemask(curses.ALL_MOUSE_EVENTS | curses.REPORT_MOUSE_POSITION)

    curses.start_color()
    curses.use_default_colors()
    curses.init_pair(1, curses.COLOR_MAGENTA, -1) # Title / Pink
    curses.init_pair(2, curses.COLOR_GREEN, -1)   # Connected
    curses.init_pair(3, curses.COLOR_CYAN, -1)    # SSID
    curses.init_pair(4, curses.COLOR_BLACK, curses.COLOR_WHITE) # Selected
    curses.init_pair(5, curses.COLOR_YELLOW, -1)  # Status / Key
    curses.init_pair(6, curses.COLOR_WHITE, -1)   # Subtle

    # Start background scanner
    scan_thread = threading.Thread(target=scan_worker, daemon=True)
    scan_thread.start()

    selected_idx = 0
    scroll_offset = 0
    spinner = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]
    spin_idx = 0

    try:
        while True:
            spin_idx = (spin_idx + 1) % len(spinner)
            max_y, max_x = stdscr.getmaxyx()
            stdscr.erase()

            with lock:
                items = list(networks.items())
                cur_saved = set(saved_conns)
                cur_dev = wifi_dev
                cur_ip = active_ip
                cur_active_conn = active_conn

            # Sort: Connected first -> Saved -> Signal strength descending -> Name
            def sort_key(item):
                (ssid, band), data = item
                is_connected = data["in_use"]
                is_saved = ssid in cur_saved
                return (
                    not is_connected,
                    not is_saved,
                    -data["signal"],
                    ssid.lower(),
                    band
                )

            items.sort(key=sort_key)
            total_items = len(items)

            list_start_y = 4
            visible_rows = max(1, max_y - 7)

            # Clamp selection and auto-scroll viewport
            if total_items == 0:
                selected_idx = 0
                scroll_offset = 0
            else:
                selected_idx = max(0, min(selected_idx, total_items - 1))
                if selected_idx < scroll_offset:
                    scroll_offset = selected_idx
                elif selected_idx >= scroll_offset + visible_rows:
                    scroll_offset = selected_idx - visible_rows + 1
                max_scroll = max(0, total_items - visible_rows)
                scroll_offset = max(0, min(scroll_offset, max_scroll))

            visible_slice = items[scroll_offset : scroll_offset + visible_rows]

            # Header Line 0
            header = f"   WI-FI NETWORKS {spinner[spin_idx]} (Live Continuous Scan) "
            stdscr.attron(curses.color_pair(1) | curses.A_BOLD)
            stdscr.addstr(0, 0, header[:max_x-1])
            stdscr.attroff(curses.color_pair(1) | curses.A_BOLD)

            # Header Line 1: Active Connection Status
            if cur_active_conn:
                act_ssid, act_band = cur_active_conn
                ip_str = f"  IP: {cur_ip}" if cur_ip else ""
                conn_header = f" ✔ Connected: {act_ssid} [{act_band}]{ip_str}"
                stdscr.attron(curses.color_pair(2) | curses.A_BOLD)
                stdscr.addstr(1, 0, conn_header[:max_x-1])
                stdscr.attroff(curses.color_pair(2) | curses.A_BOLD)
            else:
                stdscr.addstr(1, 0, " 󰤮 Disconnected (No active network)"[:max_x-1], curses.A_DIM)

            # Header Line 2: General Info & Scrolling
            scroll_info = ""
            if total_items > visible_rows:
                scroll_info = f" | {selected_idx + 1}/{total_items} (▲/▼ to scroll)"
            dev_label = f" | Dev: {cur_dev}" if cur_dev else ""
            sub_header = f" Active networks: {total_items}{dev_label}{scroll_info}"
            stdscr.addstr(2, 0, sub_header[:max_x-1], curses.A_DIM)

            if not items:
                stdscr.attron(curses.color_pair(5))
                stdscr.addstr(4, 3, "Scanning for Wi-Fi networks... Please wait...")
                stdscr.attroff(curses.color_pair(5))

            # Render rows
            for row_i, ((ssid, band), data) in enumerate(visible_slice):
                row_y = list_start_y + row_i
                if row_y >= max_y - 3:
                    break

                idx = scroll_offset + row_i
                is_connected = data["in_use"]
                is_saved = ssid in cur_saved
                sig_icon = get_wifi_icons(data["signal"], data["is_secured"])
                lock_icon = "" if data["is_secured"] else ""
                sec_label = data["security"] if data["security"] and data["security"] != "--" else "Open"
                if len(sec_label) > 12:
                    sec_label = sec_label[:12]

                status_tag = ""
                if is_connected:
                    status_tag = " ✔ Connected"
                elif is_saved:
                    status_tag = " [Saved]"

                display_ssid = ssid[:24]
                line_str = f"{sig_icon} {lock_icon}  {display_ssid:<24}  {band:<7}  {sec_label:<12}{status_tag:<14}  [{data['signal']:>3}%]"
                line_str = line_str[:max_x - 4]

                if idx == selected_idx:
                    stdscr.attron(curses.color_pair(4) | curses.A_BOLD)
                    stdscr.addstr(row_y, 0, f" ▶ {line_str:<{max_x-4}} ")
                    stdscr.attroff(curses.color_pair(4) | curses.A_BOLD)
                else:
                    if is_connected:
                        stdscr.attron(curses.color_pair(2) | curses.A_BOLD)
                    elif is_saved:
                        stdscr.attron(curses.color_pair(3) | curses.A_BOLD)
                    else:
                        stdscr.attron(curses.color_pair(6))

                    stdscr.addstr(row_y, 0, f"   {line_str}")

                    if is_connected:
                        stdscr.attroff(curses.color_pair(2) | curses.A_BOLD)
                    elif is_saved:
                        stdscr.attroff(curses.color_pair(3) | curses.A_BOLD)
                    else:
                        stdscr.attroff(curses.color_pair(6))

            # Footer
            stdscr.attron(curses.color_pair(5))
            stdscr.addstr(max_y - 2, 0, f" 󰋼 {status_msg}"[:max_x-1])
            stdscr.attroff(curses.color_pair(5))

            footer = " [Enter/Click] Connect  [d] Disconnect  [u] Forget  [p] Portal  [r] Rescan  [q] Exit "
            stdscr.addstr(max_y - 1, 0, footer[:max_x-1], curses.A_DIM)

            stdscr.refresh()

            try:
                ch = stdscr.getch()
            except Exception:
                ch = -1

            if ch == curses.KEY_MOUSE:
                try:
                    _, mx, my, _, bstate = curses.getmouse()
                    # Mouse wheel scroll up (Button 4)
                    if bstate & (curses.BUTTON4_PRESSED | curses.BUTTON4_CLICKED | 0x10000 | 0x20000 | 0x80000):
                        selected_idx = max(0, selected_idx - 2)
                    # Mouse wheel scroll down (Button 5)
                    elif bstate & (curses.BUTTON5_PRESSED | curses.BUTTON5_CLICKED | 0x200000 | 0x400000 | 0x800000):
                        selected_idx = min(total_items - 1, selected_idx + 2)
                    # Mouse left click
                    elif bstate & (curses.BUTTON1_CLICKED | curses.BUTTON1_PRESSED | curses.BUTTON1_RELEASED):
                        clicked_row = my - list_start_y
                        if 0 <= clicked_row < len(visible_slice):
                            selected_idx = scroll_offset + clicked_row
                            (sel_ssid, sel_band), sel_data = items[selected_idx]
                            if sel_data["in_use"]:
                                status_msg = f"Already connected to {sel_ssid}. Press 'd' to disconnect."
                            elif sel_ssid in cur_saved or not sel_data["is_secured"]:
                                connect_network(sel_ssid)
                            else:
                                pwd = prompt_password(stdscr, sel_ssid)
                                if pwd:
                                    connect_network(sel_ssid, pwd)
                except Exception:
                    pass
            elif ch in (ord('q'), ord('Q'), 27):
                break
            elif ch in (ord('r'), ord('R')):
                status_msg = "Rescanning networks..."
                trigger_rescan_event.set()
            elif ch in (ord('p'), ord('P')):
                status_msg = "Opening Captive Portal..."
                subprocess.Popen(["firefox", "http://neverssl.com"])
            elif ch in (ord('n'), ord('N')):
                try:
                    subprocess.Popen(["footclient", "-a", "termfloat", "-T", "Network Manager (NMTUI)", "nmtui"])
                except Exception:
                    subprocess.Popen(["foot", "--app-id=termfloat", "-T", "Network Manager (NMTUI)", "-e", "nmtui"])
            elif ch in (curses.KEY_UP, ord('k')):
                selected_idx = max(0, selected_idx - 1)
            elif ch in (curses.KEY_DOWN, ord('j')):
                selected_idx = min(total_items - 1, selected_idx + 1)
            elif ch in (curses.KEY_NPAGE, 4): # Page Down or Ctrl+D
                selected_idx = min(total_items - 1, selected_idx + max(1, visible_rows - 2))
            elif ch in (curses.KEY_PPAGE, 21): # Page Up or Ctrl+U
                selected_idx = max(0, selected_idx - max(1, visible_rows - 2))
            elif ch in (curses.KEY_HOME, ord('g')):
                selected_idx = 0
            elif ch in (curses.KEY_END, ord('G')):
                selected_idx = max(0, total_items - 1)
            elif ch in (curses.KEY_ENTER, 10, 13):
                if items and selected_idx < len(items):
                    (sel_ssid, sel_band), sel_data = items[selected_idx]
                    if sel_data["in_use"]:
                        status_msg = f"Already connected to {sel_ssid}. Press 'd' to disconnect."
                    elif sel_ssid in cur_saved or not sel_data["is_secured"]:
                        connect_network(sel_ssid)
                    else:
                        pwd = prompt_password(stdscr, sel_ssid)
                        if pwd:
                            connect_network(sel_ssid, pwd)
            elif ch in (ord('d'), ord('D')):
                disconnect_active()
            elif ch in (ord('u'), ord('U'), curses.KEY_DC):
                if items and selected_idx < len(items):
                    (sel_ssid, _), _ = items[selected_idx]
                    if sel_ssid in cur_saved:
                        forget_network(sel_ssid)
                    else:
                        status_msg = f"{sel_ssid} is not a saved connection."

    finally:
        running = False
        trigger_rescan_event.set()

if __name__ == "__main__":
    curses.wrapper(curses_main)
