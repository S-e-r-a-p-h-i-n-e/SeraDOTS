// modules/tray/Tray.qml — BACKEND ONLY
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.SystemTray

QtObject {
    readonly property string moduleType: "custom"
    readonly property var    items:      SystemTray.items.values

    // Keyed on lowercased title or id fragment — whichever matches first.
    // Covers the most commonly installed tray apps.
    readonly property var iconMap: ({
        // ── Network ───────────────────────────────────────────────────────
        "nm-applet":                    "󰤨",
        "network manager":              "󰤨",
        "networkmanager":               "󰤨",
        "connman":                      "󰤨",
        "wicd":                         "󰤨",

        // ── Bluetooth ─────────────────────────────────────────────────────
        "blueman":                      "󰂯",
        "bluetooth":                    "󰂯",

        // ── Audio ─────────────────────────────────────────────────────────
        "pavucontrol":                  "󰕾",
        "pulseaudio":                   "󰕾",
        "pipewire":                     "󰕾",
        "easyeffects":                  "󱡫",
        "jamesdsp":                     "󱡫",
        "helvum":                       "󰕾",

        // ── Storage / Drives ──────────────────────────────────────────────
        "udiskie":                      "󰕓",
        "udisks":                       "󰕓",
        "disk":                         "󰕓",

        // ── Clipboard ─────────────────────────────────────────────────────
        "copyq":                        "󰅌",
        "parcellite":                   "󰅌",
        "clipman":                      "󰅌",
        "cliphist":                     "󰅌",
        "klipper":                      "󰅌",

        // ── Screenshots ───────────────────────────────────────────────────
        "flameshot":                    "󰄄",
        "ksnip":                        "󰄄",
        "spectacle":                    "󰄄",

        // ── VPN ───────────────────────────────────────────────────────────
        "openvpn":                      "󰦝",
        "nordvpn":                      "󰦝",
        "protonvpn":                    "󰦝",
        "mullvad":                      "󰦝",
        "expressvpn":                   "󰦝",
        "wireguard":                    "󰦝",
        "vpn":                          "󰦝",

        // ── Cloud / Sync ──────────────────────────────────────────────────
        "dropbox":                      "󰇣",
        "megasync":                     "󰇣",
        "insync":                       "󰇣",
        "nextcloud":                    "󰇣",
        "onedrive":                     "󰇣",
        "syncthing":                    "󰒖",

        // ── Chat / Social ─────────────────────────────────────────────────
        "discord":                      "󰙯",
        "vesktop":                      "󰙯",
        "vencord":                      "󰙯",
        "telegram":                     "󰔁",
        "signal":                       "󰍡",
        "slack":                        "󰒱",
        "teams":                        "󰊻",
        "element":                      "󰍡",
        "fractal":                      "󰍡",

        // ── Music ─────────────────────────────────────────────────────────
        "spotify":                      "󰓇",
        "strawberry":                   "󰝚",
        "rhythmbox":                    "󰝚",
        "clementine":                   "󰝚",
        "lollypop":                     "󰝚",
        "deadbeef":                     "󰝚",

        // ── Password Managers ─────────────────────────────────────────────
        "keepassxc":                    "󰌋",
        "bitwarden":                    "󰌋",
        "enpass":                       "󰌋",
        "1password":                    "󰌋",

        // ── System / Power ────────────────────────────────────────────────
        "redshift":                     "󰌵",
        "gammastep":                    "󰌵",
        "caffeine":                     "󰛊",
        "xfce4-power-manager":          "󰁹",
        "tlp":                          "󰁹",
        "auto-cpufreq":                 "󰍛",
        "thermald":                     "󰔏",
        "cpupower":                     "󰍛",

        // ── Printers ──────────────────────────────────────────────────────
        "system-config-printer":        "󰐪",
        "cups":                         "󰐪",
        "print":                        "󰐪",

        // ── Input Method ──────────────────────────────────────────────────
        "ibus":                         "󰌌",
        "fcitx":                        "󰌌",
        "fcitx5":                       "󰌌",

        // ── Gaming ────────────────────────────────────────────────────────
        "steam":                        "󰓓",
        "lutris":                       "󰮂",
        "heroic":                       "󰮂",
        "bottles":                      "󰮂",
        "minigalaxy":                   "󰮂",

        // ── GPU / Display ─────────────────────────────────────────────────
        "nvidia-settings":              "󰾲",
        "supergfxctl":                  "󰾲",
        "optimus-manager":              "󰾲",
        "amdgpu":                       "󰾲",
        "corectrl":                     "󰾲",

        // ── Torrents / Downloads ──────────────────────────────────────────
        "qbittorrent":                  "󰇚",
        "deluge":                       "󰇚",
        "transmission":                 "󰇚",
        "filezilla":                    "󰇚",

        // ── Misc ──────────────────────────────────────────────────────────
        "mailspring":                   "󰇰",
        "thunderbird":                  "󰇰",
        "evolution":                    "󰇰",
        "mail":                         "󰇰",
        "solaar":                       "󰍽",
        "piper":                        "󰍽",
        "openrgb":                      "󰌁",
        "polychromatic":                "󰌁",
        "chrome_status_icon":           "󰙯", // this is vesktop (cause it is hella scuffed and apparently "vesktop" isnt being detected)
    })

    function iconFor(item) {
        // Safely grab title and id, defaulting to empty strings if null
        let title = (item.title || "").toLowerCase().trim()
        let id = (item.id || "").toLowerCase().trim()

        // 1. Try exact title match first
        if (iconMap[title]) return iconMap[title]

        // 2. Try matching any iconMap key as a substring of title or id
        for (let k in iconMap) {
            if (title.includes(k) || id.includes(k)) return iconMap[k]
        }

        // 3. Hardened Fallback: If title has text, use first letter. Otherwise, return a default icon.
        if (title.length > 0) {
            return title.substring(0, 1).toUpperCase()
        } else if (id.length > 0) {
            return id.substring(0, 1).toUpperCase() // Fallback to ID's first letter if title is completely empty
        } else {
            return "󰍜" // Generic dot/circle fallback for completely broken SNI implementations
        }
    }
}
