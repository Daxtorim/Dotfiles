#!/usr/bin/env python3

import functools
import json
import os
import re
import subprocess as sp

import gi

gi.require_version("Gtk", "3.0")
from gi.repository import Gtk

ICON_THEME = Gtk.IconTheme.get_default()
ICON_SIZE = 32
PLACEHOLDER_ICON = "fedora-logo-icon"


def get_placeholder_icon():
    return ICON_THEME.lookup_icon(PLACEHOLDER_ICON, ICON_SIZE, 0).get_filename()


@functools.cache
def find_icon_name(window_class: str) -> str:
    icon_name = ""

    launcher = ""
    launcher_dirs = [
        "/usr/share/applications",
        "/var/lib/flatpak/exports/share/applications",
        os.path.expanduser("~/.local/share/applications"),
    ]
    for dir in launcher_dirs:
        for filename in os.listdir(dir):
            if re.search(f"{window_class}.*desktop$", filename, re.IGNORECASE):
                launcher = os.path.join(dir, filename)
                break
        else:
            continue
        break  # only break if inner loop did break as well

    if not launcher:
        return get_placeholder_icon()

    with open(launcher) as fin:
        lines = fin.readlines()
        for line in lines:
            if line.lower().find("icon=") != -1:
                icon_name = line.split("=")[1].strip()
                break
        else:
            return get_placeholder_icon()

    return ICON_THEME.lookup_icon(icon_name, ICON_SIZE, 0).get_filename()


def main() -> str:
    clients = json.loads(sp.check_output("hyprctl clients -j", shell=True))

    if not clients:
        splash = sp.check_output("hyprctl splash", shell=True).decode("utf-8")
        return json.dumps(
            [{"css_class": "ws ws-splash", "name": splash.strip()}],
            separators=(",", ":"),
        )

    workspaces = json.loads(sp.check_output("hyprctl workspaces -j", shell=True))

    workspace_clients = {}
    for ws in workspaces:
        workspace_clients[ws["id"]] = []

    # sort by window class
    clients = sorted(clients, key=lambda x: x["class"])
    for client in clients:
        client["icon_path"] = find_icon_name(client["class"])
        ws_id = client["workspace"]["id"]
        workspace_clients[ws_id].append(client)

    monitors = json.loads(sp.check_output("hyprctl monitors -j", shell=True))
    active_ws = [monitor["activeWorkspace"]["id"] for monitor in monitors]

    workspace_components = []

    workspaces = sorted(workspaces, key=lambda x: x["id"])
    for ws in workspaces:
        id = ws["id"]

        # Add placeholder icon
        if not workspace_clients[id]:
            client = {"icon_path": get_placeholder_icon()}
            workspace_clients[id].append(client)

        css_class = f"ws ws-{id} "
        css_class += "ws-active" if id in active_ws else "ws-inactive"

        workspace = {
            "css_class": css_class,
            "name": ws["name"],
            "clients": workspace_clients[id],
        }
        workspace_components.append(workspace)

    # compact separators to make this work with eww
    return json.dumps(workspace_components, separators=(",", ":"))


if __name__ == "__main__":
    print(main())
