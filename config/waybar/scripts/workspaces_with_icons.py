#!/usr/bin/env python3
import gi
import json
import subprocess
from gi.repository import Gtk

gi.require_version('Gtk', '3.0')  # GTK3 を明示的に指定

theme = Gtk.IconTheme.get_default()

# Hyprland の情報を取得
active_ws = json.loads(subprocess.check_output(["hyprctl", "activeworkspace", "-j"]))
workspaces = json.loads(subprocess.check_output(["hyprctl", "workspaces", "-j"]))
clients = json.loads(subprocess.check_output(["hyprctl", "clients", "-j"]))

result = []

# 各ワークスペースの情報を処理
for ws in workspaces:
    wid = ws["id"]
    active = wid == active_ws["id"]
    visible = ws["windows"] > 0
    apps = [c["class"] for c in clients if c["workspace"]["id"] == wid]

    icons_markup = ""
    for app in sorted(set(apps)):
        info = theme.lookup_icon(app.lower(), 16, 0)
        if info:
            path = info.get_filename()
            icons_markup += f' <img src="{path}" width="16" height="16"/>'
        else:
            icons_markup += f' <span>[{app}]</span>'

    # Waybar に渡すオブジェクト
    result.append({
        "text": f"{wid}{icons_markup}",
        "markup": "pango",
        "class": (["active"] if active else []) + (["visible"] if visible else []),
        "id": str(wid)
    })

print(json.dumps(result))
