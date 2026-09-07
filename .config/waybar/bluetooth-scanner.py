#!/usr/bin/env python3
import curses
import os
import re
import subprocess
import sys
import threading
import time

devices = {}
lock = threading.Lock()
running = True
show_all = False
status_msg = "Scanning continuously for nearby devices..."

def is_named(name, mac):
    if not name or name.strip() == "" or name == mac:
        return False
    clean_mac = mac.replace(":", "").lower()
    clean_name = name.replace(":", "").replace("-", "").lower()
    if clean_name == clean_mac:
        return False
    # Filter anonymous hex IDs
    if re.fullmatch(r'[0-9a-fA-F]{12,}', name.strip()):
        return False
    return True

def get_icon(name, icon_type=""):
    name_lower = name.lower()
    icon_lower = icon_type.lower()
    if any(x in icon_lower for x in ["headset", "headphone"]) or any(x in name_lower for x in ["wh-", "wf-", "airpods", "buds", "headphone", "headset", "ch520", "ch720", "xm4", "xm5"]):
        return "🎧"
    if "speaker" in icon_lower or "audio" in icon_lower or any(x in name_lower for x in ["speaker", "sound", "soundbox", "boom", "jbl", "marshall"]):
        return "🔊"
    if "mouse" in icon_lower or "mouse" in name_lower:
        return "󰍽"
    if "keyboard" in icon_lower or "keyboard" in name_lower:
        return "⌨"
    if "gamepad" in icon_lower or "remote" in name_lower or "gamepad" in name_lower:
        return "🎮"
    if "phone" in icon_lower or any(x in name_lower for x in ["iphone", "galaxy", "pixel", "xiaomi", "redmi", "oppo"]):
        return "📱"
    return "󰂯"

def fetch_device_info(mac):
    try:
        info_out = subprocess.check_output(["bluetoothctl", "info", mac], text=True, stderr=subprocess.DEVNULL)
        name = ""
        icon = ""
        is_connected = False
        is_paired = False
        bat = ""
        
        for l in info_out.splitlines():
            l = l.strip()
            if l.startswith("Name:"):
                name = l.split("Name:", 1)[1].strip()
            elif l.startswith("Alias:") and not name:
                name = l.split("Alias:", 1)[1].strip()
            elif l.startswith("Icon:"):
                icon = l.split("Icon:", 1)[1].strip()
            elif l.startswith("Connected: yes"):
                is_connected = True
            elif l.startswith("Paired: yes"):
                is_paired = True
            elif "Battery Percentage:" in l:
                try:
                    bat = l.split("(")[1].split(")")[0]
                except Exception:
                    pass

        with lock:
            if mac in devices:
                if name and is_named(name, mac):
                    devices[mac]["name"] = name
                if icon:
                    devices[mac]["icon"] = icon
                devices[mac]["connected"] = is_connected
                devices[mac]["paired"] = is_paired
                if bat:
                    devices[mac]["battery"] = bat
                devices[mac]["updated"] = time.time()
    except Exception:
        pass

def delayed_resolver():
    while running:
        time.sleep(1.5)
        to_check = []
        with lock:
            for mac, d in devices.items():
                if not is_named(d["name"], mac):
                    to_check.append(mac)
        for mac in to_check[:5]:
            if not running:
                break
            fetch_device_info(mac)

def bt_reader(proc):
    global running
    mac_pattern = re.compile(r'([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}')
    known_names = {}

    # Cache all known device names from BlueZ
    try:
        out = subprocess.check_output(["bluetoothctl", "devices"], text=True, stderr=subprocess.DEVNULL)
        for line in out.splitlines():
            m = mac_pattern.search(line)
            if m:
                mac = m.group(0)
                name = line.split(mac, 1)[1].strip()
                if is_named(name, mac):
                    known_names[mac] = name
    except Exception:
        pass

    # Pre-populate with paired devices
    try:
        out = subprocess.check_output(["bluetoothctl", "devices", "Paired"], text=True, stderr=subprocess.DEVNULL)
        for line in out.splitlines():
            m = mac_pattern.search(line)
            if m:
                mac = m.group(0)
                name = known_names.get(mac, line.split(mac, 1)[1].strip())
                with lock:
                    devices[mac] = {
                        "name": name if name else mac,
                        "icon": "",
                        "connected": False,
                        "paired": True,
                        "battery": "",
                        "rssi": -999,
                        "updated": time.time()
                    }
                fetch_device_info(mac)
    except Exception:
        pass

    while running and proc.poll() is None:
        line = proc.stdout.readline()
        if not line:
            break
        line = line.strip()

        # Handle device removal by BlueZ
        if "[DEL] Device" in line:
            m = mac_pattern.search(line)
            if m:
                mac = m.group(0)
                with lock:
                    if mac in devices and not devices[mac]["connected"] and not devices[mac]["paired"]:
                        del devices[mac]
            continue

        m = mac_pattern.search(line)
        if not m:
            continue
        mac = m.group(0)

        # Handle signal loss
        if "RSSI is nil" in line or "TxPower is nil" in line:
            with lock:
                if mac in devices:
                    if not devices[mac]["paired"] and not devices[mac]["connected"]:
                        del devices[mac]
                    else:
                        devices[mac]["rssi"] = -999
            continue

        with lock:
            if mac not in devices:
                dev_name = known_names.get(mac, mac)
                devices[mac] = {
                    "name": dev_name,
                    "icon": "",
                    "connected": False,
                    "paired": False,
                    "battery": "",
                    "rssi": -999,
                    "updated": time.time()
                }

            if "[NEW] Device" in line:
                name = line.split(mac, 1)[1].strip()
                if name and is_named(name, mac):
                    devices[mac]["name"] = name
                    known_names[mac] = name
                devices[mac]["updated"] = time.time()
            elif "[CHG] Device" in line:
                if " Name: " in line:
                    n = line.split(" Name: ", 1)[1].strip()
                    if is_named(n, mac):
                        devices[mac]["name"] = n
                        known_names[mac] = n
                elif " Alias: " in line:
                    a = line.split(" Alias: ", 1)[1].strip()
                    if is_named(a, mac):
                        devices[mac]["name"] = a
                        known_names[mac] = a
                elif " Icon: " in line:
                    devices[mac]["icon"] = line.split(" Icon: ", 1)[1].strip()
                elif " Connected: yes" in line:
                    devices[mac]["connected"] = True
                elif " Connected: no" in line:
                    devices[mac]["connected"] = False
                elif " Paired: yes" in line:
                    devices[mac]["paired"] = True
                elif " Paired: no" in line:
                    devices[mac]["paired"] = False
                elif " RSSI: " in line:
                    try:
                        devices[mac]["rssi"] = int(line.split(" RSSI: ", 1)[1].split()[0], 0)
                    except Exception:
                        pass
                devices[mac]["updated"] = time.time()

def connect_device(proc, mac, name):
    def _worker():
        global status_msg
        try:
            with lock:
                is_paired = devices.get(mac, {}).get("paired", False)

            subprocess.run(["notify-send", "-i", "bluetooth", "Bluetooth", f"Connecting to {name}..."])
            proc.stdin.write(f"trust {mac}\n")
            proc.stdin.flush()

            if not is_paired:
                status_msg = f"Pairing with {name}..."
                proc.stdin.write(f"pair {mac}\n")
                proc.stdin.flush()
                t0 = time.time()
                while time.time() - t0 < 6.0:
                    with lock:
                        if devices.get(mac, {}).get("paired", False):
                            break
                    time.sleep(0.2)

            status_msg = f"Connecting to {name}..."
            proc.stdin.write(f"connect {mac}\n")
            proc.stdin.flush()

            t0 = time.time()
            connected = False
            while time.time() - t0 < 8.0:
                with lock:
                    if devices.get(mac, {}).get("connected", False):
                        connected = True
                        break
                time.sleep(0.3)

            if connected:
                status_msg = f"Connected to {name}!"
                subprocess.run(["notify-send", "-i", "bluetooth", "Bluetooth", f"Connected: {name}"])
            else:
                status_msg = f"Connection request sent to {name}."
        except Exception as e:
            status_msg = f"Error: {e}"

    threading.Thread(target=_worker, daemon=True).start()

def disconnect_device(proc, mac, name):
    global status_msg
    status_msg = f"Disconnected: {name}"
    try:
        proc.stdin.write(f"disconnect {mac}\n")
        proc.stdin.flush()
        subprocess.run(["notify-send", "-i", "bluetooth", "Bluetooth", f"Disconnected: {name}"])
    except Exception as e:
        status_msg = f"Error: {e}"

def unpair_device(proc, mac, name):
    global status_msg
    status_msg = f"Removed device: {name}"
    try:
        proc.stdin.write(f"remove {mac}\n")
        proc.stdin.flush()
        with lock:
            if mac in devices:
                del devices[mac]
        subprocess.run(["notify-send", "-i", "bluetooth", "Bluetooth", f"Removed: {name}"])
    except Exception as e:
        status_msg = f"Error: {e}"

def curses_main(stdscr):
    global running, status_msg, show_all
    curses.curs_set(0)
    stdscr.nodelay(True)
    stdscr.timeout(150)
    curses.mousemask(curses.ALL_MOUSE_EVENTS | curses.REPORT_MOUSE_POSITION)

    curses.start_color()
    curses.use_default_colors()
    curses.init_pair(1, curses.COLOR_MAGENTA, -1) # Title / Pink
    curses.init_pair(2, curses.COLOR_GREEN, -1)   # Connected
    curses.init_pair(3, curses.COLOR_CYAN, -1)    # Named
    curses.init_pair(4, curses.COLOR_BLACK, curses.COLOR_WHITE) # Selected
    curses.init_pair(5, curses.COLOR_YELLOW, -1)  # Status / Key
    curses.init_pair(6, curses.COLOR_WHITE, -1)   # Dim / subtle

    proc = subprocess.Popen(
        ["bluetoothctl"],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        text=True,
        bufsize=1
    )

    proc.stdin.write("power on\n")
    proc.stdin.write("pairable on\n")
    proc.stdin.write("agent on\n")
    proc.stdin.write("default-agent\n")
    proc.stdin.write("scan on\n")
    proc.stdin.flush()

    reader_thread = threading.Thread(target=bt_reader, args=(proc,), daemon=True)
    reader_thread.start()

    resolver_thread = threading.Thread(target=delayed_resolver, daemon=True)
    resolver_thread.start()

    selected_idx = 0
    scroll_offset = 0
    spinner = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]
    spin_idx = 0

    try:
        while True:
            spin_idx = (spin_idx + 1) % len(spinner)
            max_y, max_x = stdscr.getmaxyx()
            stdscr.erase()

            now = time.time()
            # Automatic expiration: prune devices that stopped broadcasting > 10s ago
            with lock:
                expired = [
                    mac for mac, d in devices.items()
                    if not d["paired"] and not d["connected"] and (now - d["updated"] > 10.0)
                ]
                for mac in expired:
                    del devices[mac]
                all_items = list(devices.items())

            visible_devs = []
            hidden_count = 0
            for mac, data in all_items:
                has_name = is_named(data["name"], mac)
                if has_name or show_all:
                    visible_devs.append((mac, data))
                else:
                    hidden_count += 1

            # Sort: Connected first -> Paired -> Higher RSSI -> Name
            def sort_key(item):
                mac, d = item
                is_active = (d["rssi"] != -999 or d["connected"])
                return (
                    not d["connected"],
                    not (d["paired"] and is_active),
                    not d["paired"],
                    -d["rssi"] if d["rssi"] != -999 else 999,
                    d["name"].lower()
                )

            visible_devs.sort(key=sort_key)
            total_devs = len(visible_devs)

            list_start_y = 4
            visible_rows = max(1, max_y - 7)

            # Clamp selection and auto-scroll viewport
            if total_devs == 0:
                selected_idx = 0
                scroll_offset = 0
            else:
                selected_idx = max(0, min(selected_idx, total_devs - 1))
                if selected_idx < scroll_offset:
                    scroll_offset = selected_idx
                elif selected_idx >= scroll_offset + visible_rows:
                    scroll_offset = selected_idx - visible_rows + 1
                max_scroll = max(0, total_devs - visible_rows)
                scroll_offset = max(0, min(scroll_offset, max_scroll))

            visible_slice = visible_devs[scroll_offset : scroll_offset + visible_rows]

            # Header Line 0
            header = f"  BLUETOOTH DEVICES {spinner[spin_idx]} (Live Continuous Scan) "
            stdscr.attron(curses.color_pair(1) | curses.A_BOLD)
            stdscr.addstr(0, 0, header[:max_x-1])
            stdscr.attroff(curses.color_pair(1) | curses.A_BOLD)

            # Header Line 1: Connected Devices
            connected_items = [(d["name"], d.get("battery")) for _, d in all_items if d["connected"]]
            if connected_items:
                conn_strs = [f"{n} ({b}%)" if b else n for n, b in connected_items]
                conn_header = f" ✔ Connected: {', '.join(conn_strs)}"
                stdscr.attron(curses.color_pair(2) | curses.A_BOLD)
                stdscr.addstr(1, 0, conn_header[:max_x-1])
                stdscr.attroff(curses.color_pair(2) | curses.A_BOLD)
            else:
                stdscr.addstr(1, 0, " 󰂯 Disconnected (No active devices)"[:max_x-1], curses.A_DIM)

            # Header Line 2: Active count & scroll info
            sub_header = f" Active devices: {total_devs}"
            if hidden_count > 0 and not show_all:
                sub_header += f" ({hidden_count} unnamed hidden - 'a' to toggle)"
            elif show_all:
                sub_header += " (Showing all)"
            if total_devs > visible_rows:
                sub_header += f" | {selected_idx + 1}/{total_devs} (▲/▼ to scroll)"
            stdscr.addstr(2, 0, sub_header[:max_x-1], curses.A_DIM)

            if not visible_devs:
                stdscr.attron(curses.color_pair(5))
                stdscr.addstr(4, 3, "Scanning... Turn on device or enable Pairing mode...")
                stdscr.attroff(curses.color_pair(5))

            # Render device list
            for row_i, (mac, data) in enumerate(visible_slice):
                row_y = list_start_y + row_i
                if row_y >= max_y - 3:
                    break

                idx = scroll_offset + row_i
                name = data["name"]
                icon = get_icon(name, data.get("icon", ""))
                
                status_tag = ""
                if data["connected"]:
                    bat = f" ({data['battery']}%)" if data.get("battery") else ""
                    status_tag = f"  ✔ Connected{bat}"
                elif data["paired"]:
                    if data["rssi"] != -999:
                        status_tag = "  [Paired]"
                    else:
                        status_tag = "  [Paired - Offline]"

                rssi_tag = f" [{data['rssi']}dBm]" if data["rssi"] != -999 else ""
                display_name = name[:26]
                line_str = f"{icon}  {display_name:<26}  {mac:<17}{status_tag}{rssi_tag}"
                line_str = line_str[:max_x - 4]

                if idx == selected_idx:
                    stdscr.attron(curses.color_pair(4) | curses.A_BOLD)
                    stdscr.addstr(row_y, 0, f" ▶ {line_str:<{max_x-4}} ")
                    stdscr.attroff(curses.color_pair(4) | curses.A_BOLD)
                else:
                    if data["connected"]:
                        stdscr.attron(curses.color_pair(2) | curses.A_BOLD)
                    else:
                        stdscr.attron(curses.color_pair(3))
                    stdscr.addstr(row_y, 0, f"   {line_str}")
                    if data["connected"]:
                        stdscr.attroff(curses.color_pair(2) | curses.A_BOLD)
                    else:
                        stdscr.attroff(curses.color_pair(3))

            # Footer status & shortcuts
            stdscr.attron(curses.color_pair(5))
            stdscr.addstr(max_y - 2, 0, f" 󰋼 {status_msg}"[:max_x-1])
            stdscr.attroff(curses.color_pair(5))

            footer = " [Enter/Click] Connect  [d] Disconnect  [u] Unpair  [a] Toggle Beacons  [q/Esc] Exit "
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
                        selected_idx = min(total_devs - 1, selected_idx + 2)
                    # Mouse left click
                    elif bstate & (curses.BUTTON1_CLICKED | curses.BUTTON1_PRESSED | curses.BUTTON1_RELEASED):
                        clicked_row = my - list_start_y
                        if 0 <= clicked_row < len(visible_slice):
                            selected_idx = scroll_offset + clicked_row
                            sel_mac, sel_data = visible_devs[selected_idx]
                            if sel_data["connected"]:
                                disconnect_device(proc, sel_mac, sel_data["name"])
                            else:
                                connect_device(proc, sel_mac, sel_data["name"])
                except Exception:
                    pass
            elif ch in (ord('q'), ord('Q'), 27):
                break
            elif ch in (ord('a'), ord('A')):
                show_all = not show_all
            elif ch in (curses.KEY_UP, ord('k')):
                selected_idx = max(0, selected_idx - 1)
            elif ch in (curses.KEY_DOWN, ord('j')):
                selected_idx = min(total_devs - 1, selected_idx + 1)
            elif ch in (curses.KEY_NPAGE, 4): # Page Down or Ctrl+D
                selected_idx = min(total_devs - 1, selected_idx + max(1, visible_rows - 2))
            elif ch in (curses.KEY_PPAGE, 21): # Page Up or Ctrl+U
                selected_idx = max(0, selected_idx - max(1, visible_rows - 2))
            elif ch in (curses.KEY_HOME, ord('g')):
                selected_idx = 0
            elif ch in (curses.KEY_END, ord('G')):
                selected_idx = max(0, total_devs - 1)
            elif ch in (curses.KEY_ENTER, 10, 13):
                if visible_devs and selected_idx < len(visible_devs):
                    sel_mac, sel_data = visible_devs[selected_idx]
                    if sel_data["connected"]:
                        disconnect_device(proc, sel_mac, sel_data["name"])
                    else:
                        connect_device(proc, sel_mac, sel_data["name"])
            elif ch in (ord('d'), ord('D')):
                if visible_devs and selected_idx < len(visible_devs):
                    sel_mac, sel_data = visible_devs[selected_idx]
                    disconnect_device(proc, sel_mac, sel_data["name"])
            elif ch in (ord('u'), ord('U'), curses.KEY_DC):
                if visible_devs and selected_idx < len(visible_devs):
                    sel_mac, sel_data = visible_devs[selected_idx]
                    unpair_device(proc, sel_mac, sel_data["name"])

    finally:
        running = False
        try:
            proc.stdin.write("scan off\n")
            proc.stdin.write("quit\n")
            proc.stdin.flush()
            proc.terminate()
            proc.wait(timeout=1)
        except Exception:
            pass

if __name__ == "__main__":
    curses.wrapper(curses_main)
