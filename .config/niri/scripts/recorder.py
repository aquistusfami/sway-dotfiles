#!/usr/bin/env python3
"""TUI cho wf-recorder (cùng kiểu cửa sổ foot nổi như rmpc ở Mod+M).

Quá trình quay chạy tách rời: đóng TUI (q) vẫn quay tiếp, mở lại để dừng.
"""
import curses, json, os, shlex, subprocess, time
from pathlib import Path

STATE = Path(os.environ.get("XDG_RUNTIME_DIR", "/tmp")) / "recorder-tui.json"
OUTDIR = Path.home() / "Videos"


def sh(cmd):
    return subprocess.run(cmd, shell=True, capture_output=True, text=True).stdout.strip()


def outputs():
    names = [l.split("Name: ")[1].split()[0] for l in sh("wf-recorder -L 2>&1").splitlines() if "Name: " in l]
    return names + ["Region (slurp)"]


def build_cmd(source, audio, fps, codec, path, geometry=None, monitor=None):
    cmd = ["wf-recorder", "-y", "-f", str(path)]
    cmd += ["-g", geometry] if geometry else ["-o", source]
    if audio == "Mic":
        cmd += ["--audio"]
    elif audio == "Desktop" and monitor:
        cmd += [f"--audio={monitor}"]
    if fps != "Native":
        cmd += ["-r", fps]
    if codec == "GPU (VAAPI)":
        cmd += ["-c", "h264_vaapi", "-d", "/dev/dri/renderD128"]
    else:
        cmd += ["-c", "libx264", "-p", "preset=veryfast", "-p", "crf=23"]
    return cmd


def load_state():
    try:
        st = json.loads(STATE.read_text())
        os.kill(st["pid"], 0)
        return st
    except (OSError, ValueError, KeyError):
        STATE.unlink(missing_ok=True)
        return None


def start(opts):
    geometry = None
    if opts["Source"].startswith("Region"):
        geometry = sh("slurp")
        if not geometry:
            return None, "Đã huỷ chọn vùng"
    monitor = sh("pactl get-default-sink") + ".monitor"
    OUTDIR.mkdir(exist_ok=True)
    path = OUTDIR / time.strftime("rec-%Y%m%d-%H%M%S.mp4")
    cmd = build_cmd(opts["Source"], opts["Audio"], opts["FPS"], opts["Codec"], path, geometry, monitor)
    # sh bọc ngoài để gửi thông báo khi xong; dừng = SIGINT vào wf-recorder (con của sh)
    script = shlex.join(cmd) + f" 2>/dev/null; notify-send -i video-x-generic 'Đã lưu bản ghi' {shlex.quote(str(path))}"
    p = subprocess.Popen(["sh", "-c", script], start_new_session=True,
                         stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    STATE.write_text(json.dumps({"pid": p.pid, "path": str(path), "t0": time.time()}))
    return load_state(), f"Đang quay → {path.name}"


def stop(st):
    subprocess.run(["pkill", "-INT", "-P", str(st["pid"]), "wf-recorder"])
    for _ in range(50):  # chờ ffmpeg ghi xong moov atom
        if load_state() is None:
            break
        time.sleep(0.1)
    STATE.unlink(missing_ok=True)
    return f"Đã lưu {Path(st['path']).name}"


def colors():
    curses.start_color(); curses.use_default_colors()
    palette = {1: (0xf3, 0xf9, 0x9d), 2: (0xff, 0x6a, 0xc1), 3: (0x5a, 0xf7, 0x8e), 4: (0x55, 0x55, 0x55), 5: (0x14, 0x14, 0x19)}
    fallback = {1: curses.COLOR_YELLOW, 2: curses.COLOR_MAGENTA, 3: curses.COLOR_GREEN, 4: curses.COLOR_WHITE, 5: curses.COLOR_BLACK}
    custom = curses.can_change_color() and curses.COLORS >= 32
    for i, (r, g, b) in palette.items():
        if custom:
            curses.init_color(16 + i, r * 1000 // 255, g * 1000 // 255, b * 1000 // 255)
        curses.init_pair(i, 16 + i if custom else fallback[i], -1)
    curses.init_pair(6, 16 + 5 if custom else fallback[5], 16 + 1 if custom else fallback[1])  # dòng chọn


def main(scr):
    curses.curs_set(0); colors(); scr.timeout(250)
    Y, P, G, B, SEL = (curses.color_pair(i) for i in (1, 2, 3, 4, 6))
    choices = {"Source": outputs(), "Audio": ["Off", "Mic", "Desktop"],
               "FPS": ["60", "30", "Native"], "Codec": ["GPU (VAAPI)", "CPU (x264)"]}
    idx = {k: 0 for k in choices}
    keys = list(choices)
    row, msg = 0, ""
    while True:
        st = load_state()
        opts = {k: choices[k][idx[k]] for k in keys}
        scr.erase()
        h, w = scr.getmaxyx()
        if st:
            el = int(time.time() - st["t0"])
            dot = "●" if el % 2 == 0 else " "
            scr.addstr(1, 3, f"{dot} REC  {el // 3600:02}:{el % 3600 // 60:02}:{el % 60:02}", P | curses.A_BOLD)
        else:
            scr.addstr(1, 3, "○ Idle", B | curses.A_BOLD)
        scr.addstr(1, max(3, w - 14), "wf-recorder", Y | curses.A_BOLD)
        scr.addstr(2, 2, "─" * (w - 4), B)
        for i, k in enumerate(keys):
            y = 4 + i * 2
            attr = SEL | curses.A_BOLD if i == row and not st else (B if st else 0)
            scr.addstr(y, 4, f" {k:<8}", Y if not st else B)
            scr.addstr(y, 16, f" ‹ {opts[k]} › ".ljust(w - 22), attr)
        y = 5 + len(keys) * 2
        scr.addstr(y, 4, f" {'Folder':<8}", Y)
        scr.addstr(y, 16, f"  {OUTDIR}"[: w - 18])
        scr.addstr(y + 2, 4, ("  ■ STOP  " if st else "  ● RECORD  "), SEL | curses.A_BOLD)
        if msg:
            scr.addstr(y + 4, 4, msg[: w - 6], G)
        scr.addstr(h - 2, 2, "─" * (w - 4), B)
        hint = "Enter dừng · o mở thư mục · q đóng (vẫn quay)" if st else "↑↓ chọn · ←→ đổi · Enter quay · o mở thư mục · q thoát"
        scr.addstr(h - 1, 3, hint[: w - 6], B)
        scr.refresh()

        c = scr.getch()
        if c in (ord("q"), 27):
            return
        if c == ord("o"):
            subprocess.Popen(["xdg-open", str(OUTDIR)], start_new_session=True,
                             stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        elif c in (10, 13, curses.KEY_ENTER, ord(" ")):
            if st:
                msg = stop(st)
            else:
                _, msg = start(opts)
        elif not st and c in (curses.KEY_UP, ord("k")):
            row = (row - 1) % len(keys)
        elif not st and c in (curses.KEY_DOWN, ord("j")):
            row = (row + 1) % len(keys)
        elif not st and c in (curses.KEY_LEFT, curses.KEY_RIGHT, ord("h"), ord("l")):
            d = -1 if c in (curses.KEY_LEFT, ord("h")) else 1
            idx[keys[row]] = (idx[keys[row]] + d) % len(choices[keys[row]])


if __name__ == "__main__":
    if os.environ.get("RECORDER_SELFTEST"):
        c = build_cmd("HDMI-A-1", "Desktop", "60", "GPU (VAAPI)", "/x.mp4", monitor="m.monitor")
        assert c[:6] == ["wf-recorder", "-y", "-f", "/x.mp4", "-o", "HDMI-A-1"] and "--audio=m.monitor" in c and "h264_vaapi" in c
        c = build_cmd("Region", "Off", "Native", "CPU (x264)", "/x.mp4", geometry="0,0 10x10")
        assert "-g" in c and "-o" not in c and "-r" not in c and "--audio" not in c
        print("ok"); raise SystemExit
    curses.wrapper(main)
