#!/usr/bin/env python3
"""
Spotlight Launcher for Wayland / Niri / Sway
macOS-style: real app icons, frecency ranking, minimal translucent panel.

Keybind: Mod+Space (set in niri config.kdl)
Capabilities:
- Applications launcher (scans .desktop entries, sorted by frecency)
- Quick Calculator (copies result to clipboard + notification)
- Web search (prefix ? / g / web)
- File / Directory navigation (common folders + fd search)
- System actions (lock, sleep, reboot, shutdown, nightlight, ...)
"""

import ast
import json
import math
import os
import re
import subprocess
import sys
import time
import urllib.parse
from pathlib import Path

HOME = str(Path.home())
SCRIPT_DIR = Path(__file__).resolve().parent
CONFIG = SCRIPT_DIR / "spotlight.ini"
CACHE = Path(os.environ.get("XDG_CACHE_HOME", f"{HOME}/.cache")) / "spotlight" / "frecency.json"
def _app_dirs():
    dirs, seen = [], set()
    data_dirs = [f"{HOME}/.local/share"]
    data_dirs += os.environ.get("XDG_DATA_DIRS", "/usr/local/share:/usr/share").split(":")
    data_dirs += ["/run/current-system/sw/share"]
    for d in data_dirs:
        appdir = str(Path(d) / "applications")
        if appdir not in seen:
            seen.add(appdir)
            dirs.append(appdir)
    return dirs


APP_ICON_DIRS = _app_dirs()

# -----------------------------------------------------------------------------
# 1. Built-in entries: (display, atype, payload)
# -----------------------------------------------------------------------------
SYSTEM_ACTIONS = [
    ("Lock Screen", "SYS", "swaylock -f"),
    ("Sleep / Suspend", "SYS", "systemctl suspend"),
    ("Restart System", "SYS", "systemctl reboot"),
    ("Power Off", "SYS", "systemctl poweroff"),
    ("Toggle Nightlight", "SYS", f"{HOME}/.config/niri/scripts/toggle-nightlight.sh"),
    ("Wallpaper Picker", "SYS", f"{HOME}/.config/niri/scripts/wallpaper-picker.sh"),
    ("Toggle Gaps", "SYS", f"{HOME}/.config/niri/scripts/toggle-gaps.sh"),
    ("System Monitor (btop)", "SYS", "foot -T btop btop"),
    ("File Manager (nnn)", "SYS", f'foot -a termfloat -T "nnn File Manager" {HOME}/.config/nnn/run-nnn.sh'),
]

PINNED_DIRS = [
    ("Home", "DIR", HOME),
    ("Downloads", "DIR", f"{HOME}/Downloads"),
    ("Documents", "DIR", f"{HOME}/Documents"),
    ("Pictures", "DIR", f"{HOME}/Pictures"),
    ("Dotfiles", "DIR", f"{HOME}/dotfiles"),
]

# -----------------------------------------------------------------------------
# 2. Frecency cache (frequency + recency)
# -----------------------------------------------------------------------------
def load_cache():
    try:
        return json.loads(CACHE.read_text())
    except Exception:
        return {}


def save_cache(data):
    try:
        CACHE.parent.mkdir(parents=True, exist_ok=True)
        CACHE.write_text(json.dumps(data))
    except Exception:
        pass


def frecency(cache, key):
    rec = cache.get(key)
    if not rec:
        return 0.0
    age_days = (time.time() - rec.get("last", 0)) / 86400
    return rec.get("count", 0) / (1 + age_days / 30)


def bump(cache, key):
    rec = cache.get(key) or {"count": 0, "last": 0}
    rec["count"] = rec.get("count", 0) + 1
    rec["last"] = time.time()
    cache[key] = rec


# -----------------------------------------------------------------------------
# 3. Gather Desktop Applications
# -----------------------------------------------------------------------------
def get_desktop_apps():
    apps = []
    seen = set()
    for adir in APP_ICON_DIRS:
        pdir = Path(adir)
        if not pdir.is_dir():
            continue
        for dfile in sorted(pdir.glob("*.desktop")):
            try:
                content = dfile.read_text(encoding="utf-8", errors="ignore")
                if "[Desktop Entry]" not in content:
                    continue
                if re.search(r"^(NoDisplay|Hidden)\s*=\s*true", content, re.MULTILINE | re.IGNORECASE):
                    continue
                if re.search(r"^Type\s*=\s*(?!Application)", content, re.MULTILINE):
                    continue

                name_m = re.search(r"^Name\s*=\s*(.+)$", content, re.MULTILINE)
                exec_m = re.search(r"^Exec\s*=\s*(.+)$", content, re.MULTILINE)
                if not name_m or not exec_m:
                    continue

                name = name_m.group(1).strip()
                if name in seen:
                    continue
                seen.add(name)

                exec_cmd = re.sub(r"%[fFuUdDnNickvm]", "", exec_m.group(1)).strip()
                if not exec_cmd:
                    continue

                icon_m = re.search(r"^Icon\s*=\s*(.+)$", content, re.MULTILINE)
                icon = icon_m.group(1).strip() if icon_m else ""

                if re.search(r"^Terminal\s*=\s*true", content, re.MULTILINE):
                    exec_cmd = f"foot -e {exec_cmd}"

                apps.append({
                    "display": name,
                    "icon": icon,
                    "atype": "APP",
                    "payload": exec_cmd,
                    "key": str(dfile),
                })
            except Exception:
                continue
    return apps


# -----------------------------------------------------------------------------
# 4. Safe Math Evaluator
# -----------------------------------------------------------------------------
def try_eval_math(expr):
    clean = expr.strip().lstrip("=").strip().replace("^", "**")
    if not re.search(r"\d", clean) or not re.search(r"[\+\-\*\/\%]", clean):
        return None
    try:
        node = ast.parse(clean, mode="eval")
        allowed = {
            "sqrt", "sin", "cos", "tan", "abs", "pow", "log", "pi", "e",
        }
        for n in ast.walk(node):
            if isinstance(n, (
                ast.Expression, ast.BinOp, ast.UnaryOp, ast.Constant,
                ast.Call, ast.Load,
                ast.Add, ast.Sub, ast.Mult, ast.Div, ast.FloorDiv,
                ast.Mod, ast.Pow, ast.USub, ast.UAdd,
            )):
                continue
            if isinstance(n, ast.Name) and n.id in allowed:
                continue
            return None
        safe = {
            "__builtins__": {},
            "sqrt": math.sqrt, "sin": math.sin, "cos": math.cos,
            "tan": math.tan, "abs": abs, "pow": pow, "log": math.log,
            "pi": math.pi, "e": math.e,
        }
        res = eval(compile(node, "<math>", "eval"), safe)
        if isinstance(res, (int, float)):
            if isinstance(res, float) and res.is_integer():
                res = int(res)
            elif isinstance(res, float):
                res = round(res, 6)
            return str(res)
    except Exception:
        return None
    return None


# -----------------------------------------------------------------------------
# 5. Main Execution Flow
# -----------------------------------------------------------------------------
def main():
    cache = load_cache()

    # Build ordered entries: apps by frecency first, then folders, then actions.
    apps = get_desktop_apps()
    apps.sort(key=lambda a: (-frecency(cache, a["key"]), a["display"].lower()))

    entries = []
    for a in apps:
        entries.append(a)
    for display, atype, payload in PINNED_DIRS:
        entries.append({"display": display, "icon": "folder", "atype": atype, "payload": payload, "key": None})
    for display, atype, payload in SYSTEM_ACTIONS:
        entries.append({"display": display, "icon": "", "atype": atype, "payload": payload, "key": None})

    # fuzzel dmenu: "<id>\t<text>\0icon\x1f<icon>" ; display text, accept id.
    lines = []
    for i, e in enumerate(entries):
        text = e["display"]
        if e["icon"]:
            text = f'{text}\0icon\x1f{e["icon"]}'
        lines.append(f"e{i}\t{text}")
    input_text = "\n".join(lines)

    cmd = [
        "fuzzel",
        "--dmenu",
        f"--config={CONFIG}",
        "--prompt=󰍉  ",
        "--placeholder=Search  ·  =2+2  ·  ? web  ·  / files",
        "--with-nth=2",
        "--accept-nth=1",
        "--match-nth=2",
    ]

    proc = subprocess.Popen(
        cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL, text=True,
    )
    selected, _ = proc.communicate(input=input_text)
    selected = selected.strip()
    if not selected:
        sys.exit(0)

    # 1. A predefined entry was chosen ("e<index>")
    if re.fullmatch(r"e\d+", selected):
        entry = entries[int(selected[1:])]
        if entry["atype"] == "APP":
            if entry["key"]:
                bump(cache, entry["key"])
                save_cache(cache)
            subprocess.Popen(entry["payload"], shell=True)
        elif entry["atype"] == "SYS":
            subprocess.Popen(entry["payload"], shell=True)
        elif entry["atype"] == "DIR":
            nnn = f"{HOME}/.config/nnn/run-nnn.sh"
            if os.path.exists(nnn):
                subprocess.Popen(f'foot -a termfloat -T "nnn File Manager" {nnn} "{entry["payload"]}"', shell=True)
            else:
                subprocess.Popen(["xdg-open", entry["payload"]])
        sys.exit(0)

    # 2. Math
    math_result = try_eval_math(selected)
    if math_result is not None:
        subprocess.run(["wl-copy", math_result], check=False)
        subprocess.run([
            "notify-send", "-i", "accessories-calculator", "-a", "Spotlight",
            f"󰃬 Calculator: {selected}", f"= {math_result}\n(Copied to clipboard)",
        ], check=False)
        sys.exit(0)

    # 3. Web search
    if re.match(r"^(\?|g |web )", selected):
        query = re.sub(r"^(\?|g|web)\s+", "", selected).strip()
        subprocess.Popen(["firefox", f"https://duckduckgo.com/?q={urllib.parse.quote_plus(query)}"])
        sys.exit(0)

    # 4. Direct URL
    if selected.startswith(("http://", "https://")) or ("." in selected and " " not in selected):
        url = selected if selected.startswith("http") else f"https://{selected}"
        subprocess.Popen(["firefox", url])
        sys.exit(0)

    # 5. File search
    if selected.startswith(("f ", "/", "~")):
        target = os.path.expanduser(re.sub(r"^f\s+", "", selected).strip())
        if os.path.exists(target):
            subprocess.Popen(["xdg-open", target])
            sys.exit(0)
        fd = subprocess.run(
            ["fd", "--hidden", "--exclude", ".git", "--max-results", "20", target, HOME],
            capture_output=True, text=True, check=False,
        )
        matches = [m for m in fd.stdout.splitlines() if m.strip()]
        if matches:
            sub = subprocess.Popen(
                ["fuzzel", "--dmenu", f"--config={CONFIG}", "--prompt=󰈞  ",
                 "--width=60", "--lines=10"],
                stdin=subprocess.PIPE, stdout=subprocess.PIPE, text=True,
            )
            picked, _ = sub.communicate(input="\n".join(matches))
            picked = picked.strip()
            if picked and os.path.exists(picked):
                subprocess.Popen(["xdg-open", picked])
        sys.exit(0)

    # 6. Fallback: run as command, else web search
    try:
        subprocess.Popen(selected, shell=True)
    except Exception:
        subprocess.Popen(["firefox", f"https://duckduckgo.com/?q={urllib.parse.quote_plus(selected)}"])


if __name__ == "__main__":
    main()
