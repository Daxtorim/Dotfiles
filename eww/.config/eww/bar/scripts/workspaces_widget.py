#!/usr/bin/env python3

import functools
import json
import os
import re
import subprocess as sp

import gi

gi.require_version("Gtk", "3.0")
from gi.repository import Gtk  # noqa

ICON_THEME = Gtk.IconTheme.get_default()
ICON_SIZE = 32
PLACEHOLDER_ICON = os.path.expanduser("~/.local/share/icons/placeholder.png")

WS_PIN_ID = 2**64  # This just needs to be a big number outside of hyprlands range


class GetOutOfLoop(Exception):
    pass


@functools.cache
def find_icon_name(window_class: str) -> str:
    launcher = ""
    launcher_dirs = [
        "/usr/share/applications",
        "/var/lib/flatpak/exports/share/applications",
        os.path.expanduser("~/.local/share/applications"),
    ]

    try:
        for dir in launcher_dirs:
            for filename in os.listdir(dir):
                if re.search(f"{window_class}.*desktop$", filename, re.IGNORECASE):
                    launcher = os.path.join(dir, filename)
                    raise GetOutOfLoop
        else:
            return PLACEHOLDER_ICON
    except GetOutOfLoop:
        pass

    icon_name = ""
    with open(launcher) as fin:
        lines = fin.readlines()
        for line in lines:
            if line.lower().find("icon=") != -1:
                icon_name = line.split("=")[1].strip()
                break
        else:
            return PLACEHOLDER_ICON

    if icon_path := ICON_THEME.lookup_icon(icon_name, ICON_SIZE, 0).get_filename():
        return icon_path
    else:
        return PLACEHOLDER_ICON


def main() -> str:
    clients = json.loads(sp.check_output("hyprctl clients -j", shell=True))

    if not clients:
        splash = sp.check_output("hyprctl splash", shell=True).decode("utf-8")
        return json.dumps(
            [{"css_class": "ws ws-splash", "name": splash.strip()}],
            separators=(",", ":"),
        )

    monitors = json.loads(sp.check_output("hyprctl monitors -j", shell=True))
    workspaces = json.loads(sp.check_output("hyprctl workspaces -j", shell=True))
    active_ws = [monitor["activeWorkspace"]["id"] for monitor in monitors]
    active_client = json.loads(sp.check_output("hyprctl activewindow -j", shell=True))

    workspace_clients = {}
    workspace_clients[WS_PIN_ID] = []
    for ws in workspaces:
        workspace_clients[ws["id"]] = []

    # sort by window class first, sort ties then by address
    clients = sorted(clients, key=lambda x: (x["class"].lower(), x["address"]))
    for cl in clients:
        cl["icon_path"] = find_icon_name(cl["class"])

        try:
            cl_active = True if active_client["address"] == cl["address"] else False
            cl["active"] = cl_active
        except KeyError:
            pass

        ws_id = cl["workspace"]["id"] if not cl["pinned"] else WS_PIN_ID
        workspace_clients[ws_id].append(cl)

    workspace_components = []

    workspaces = sorted(workspaces, key=lambda x: x["id"])
    workspaces.append({"id": WS_PIN_ID, "name": ""})
    for ws in workspaces:
        id = ws["id"]
        if id < 0:
            continue

        # Add placeholder icon
        if not workspace_clients[id]:
            if id != WS_PIN_ID:
                cl = {"icon_path": PLACEHOLDER_ICON, "active": True}
                workspace_clients[id].append(cl)
            else:
                continue

        css_class = f"ws ws-{id} ws-{ws['name']} "
        css_class += "ws-active" if id in active_ws else "ws-inactive"

        ws["css_class"] = css_class
        ws["clients"] = workspace_clients[id]
        workspace_components.append(ws)

    # compact separators to make this work with eww
    return json.dumps(workspace_components, separators=(",", ":"))


if __name__ == "__main__":
    print(main())
