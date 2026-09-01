// engine/AppEngine.qml
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property var applications: []
    property bool loading: true

    Process {
        id: fileFinder
        command: [
            "python3", "-c",
            `
import os, json, re

apps = []
seen = set()

# XDG Data Dirs with proper precedence
paths = [os.path.expanduser("~/.local/share")]
env_paths = os.environ.get("XDG_DATA_DIRS", "/usr/local/share:/usr/share").split(":")
paths.extend([p for p in env_paths if p])
paths.append("/var/lib/flatpak/exports/share")

for base in paths:
    app_dir = os.path.join(base, "applications")
    if not os.path.isdir(app_dir):
        continue
    for root_dir, _, files in os.walk(app_dir):
        for f in files:
            if not f.endswith(".desktop") or f in seen:
                continue
            seen.add(f)
            fp = os.path.join(root_dir, f)
            try:
                with open(fp, "r", encoding="utf-8", errors="ignore") as file:
                    in_entry = False
                    name, icon, exec_cmd, nodisplay = "", "", "", False
                    for line in file:
                        line = line.strip()
                        if line == "[Desktop Entry]":
                            in_entry = True
                            continue
                        elif line.startswith("["):
                            in_entry = False
                            continue

                        if in_entry:
                            if line.startswith("Name=") and not name:
                                name = line[5:].strip()
                            elif line.startswith("Icon=") and not icon:
                                icon = line[5:].strip()
                            elif line.startswith("Exec=") and not exec_cmd:
                                exec_cmd = line[5:].strip()
                            elif line.lower() == "nodisplay=true":
                                nodisplay = True

                    if name and exec_cmd and not nodisplay:
                        # Clean %U, %f, %F, %u field codes
                        exec_clean = re.sub(r"%[a-zA-Z]", "", exec_cmd).strip()
                        apps.append({
                            "name": name,
                            "icon": icon,
                            "exec": exec_clean
                        })
            except Exception:
                pass

apps.sort(key=lambda x: x["name"].lower())
print(json.dumps(apps))
`
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.applications = JSON.parse(this.text)
                } catch (e) {
                    console.warn("AppEngine: Failed to parse apps JSON", e)
                }
                root.loading = false
            }
        }
    }

    function refresh() {
        root.loading = true
        fileFinder.running = true
    }

    Component.onCompleted: refresh()
}
