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
ICON_SIZE = 128
PLACEHOLDER_ICON = os.path.expanduser("~/.local/share/icons/placeholder.svg")

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


def sort_clients_into_workspaces(clients: list, workspaces: list) -> dict:
    workspace_clients = {}
    workspace_clients[WS_PIN_ID] = []
    for ws in workspaces:
        workspace_clients[ws["id"]] = []

    active_client_address = json.loads(
        sp.check_output("hyprctl activewindow -j", shell=True)
    ).get("address")

    # sort by window class first (drop the "org.*" part), sort ties then by address
    clients = sorted(
        clients, key=lambda x: (x["class"].split(".")[-1].lower(), x["address"])
    )
    for cl in clients:
        cl["icon_path"] = find_icon_name(cl["class"])
        cl["tooltip"] = f"{cl['class']} | PID: {cl['pid']}\n{cl['title']}"
        cl["active"] = active_client_address == cl["address"]

        ws_id = cl["workspace"]["id"] if not cl["pinned"] else WS_PIN_ID

        workspace_clients[ws_id].append(cl)

    return workspace_clients


def add_css_class_and_clients(workspaces: list, workspace_clients: dict) -> list:
    shown_workspaces = []

    monitors = json.loads(sp.check_output("hyprctl monitors -j", shell=True))
    active_ws = [monitor["activeWorkspace"]["id"] for monitor in monitors]

    workspaces = sorted(workspaces, key=lambda x: x["id"])
    workspaces.append({"id": WS_PIN_ID, "name": ""})
    for ws in workspaces:
        id = ws["id"]
        if id < 0:  # skip special workspaces (scratchpads)
            continue

        # Add placeholder icon if no client exists on this workspace
        if not workspace_clients[id]:
            if id != WS_PIN_ID:
                cl = {"icon_path": PLACEHOLDER_ICON, "active": True}
                workspace_clients[id].append(cl)
            else:
                continue
        ws["clients"] = workspace_clients[id]

        css_class_list = ["ws", f"ws-{id}", f"ws-{ws['name']}"]
        css_class_list += ["ws-active"] if id in active_ws else ["ws-inactive"]
        ws["css_class"] = " ".join(css_class_list)

        shown_workspaces.append(ws)

    return shown_workspaces


def main() -> list:
    clients = json.loads(sp.check_output("hyprctl clients -j", shell=True))

    if not clients:
        splash = sp.check_output("hyprctl splash", shell=True).decode("utf-8")
        return [{"css_class": "ws ws-splash", "name": splash.strip()}]

    workspaces = json.loads(sp.check_output("hyprctl workspaces -j", shell=True))

    workspace_clients = sort_clients_into_workspaces(clients, workspaces)
    return add_css_class_and_clients(workspaces, workspace_clients)


if __name__ == "__main__":
    # compact separators to make this work with eww
    print(json.dumps(main(), separators=(",", ":")))
