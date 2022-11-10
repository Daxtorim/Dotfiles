#!/usr/bin/env python3

import json
import subprocess as sp


def main():
    nmcli_status = (
        sp.check_output("nmcli --terse device status", shell=True)
        .decode("utf-8")
        .split("\n")
    )

    for iface in nmcli_status:
        if not iface:
            continue

        iface = iface.split(":")
        iface = {
            "iface": iface[0],
            "type": iface[1],
            "status": iface[2],
            "network": iface[3],
            "icon": "",
        }

        if iface["status"] != "connected":
            continue

        if iface["type"] == "wifi":
            iface["icon"] = "﬉"
        elif iface["type"] == "ethernet":
            iface["icon"] = ""
        else:
            iface["icon"] = ""

        return json.dumps(iface, separators=(",", ":"))

    iface = {
        "iface": "N/A",
        "type": "N/A",
        "status": "disconnected",
        "network": "N/A",
        "icon": "",
    }

    return json.dumps(iface, separators=(",", ":"))


if __name__ == "__main__":
    print(main())
