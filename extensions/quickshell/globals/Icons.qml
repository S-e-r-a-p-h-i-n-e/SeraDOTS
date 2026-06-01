// globals/Icons.qml
// Centralised nerd font icon map for all modules that display app-sourced icons.
// Both Workspaces and Tray delegate their iconFor() logic here so the map
// lives in one place and is easy to extend.
//
// Usage:
//   Icons.getIcon("firefox")          → "󰈹"
//   Icons.getIcon(appClass)           → glyph or first-letter fallback
//   Icons.getIconFromItem(trayItem)   → for tray items (checks title + id)
pragma Singleton

import QtQuick

QtObject {
    id: root

    readonly property var iconMap: ({
        // ── Browsers ──────────────────────────────────────────────────────
        "firefox":                      "󰈹",
        "librewolf":                    "󰈹",
        "chromium":                     "󰊯",
        "google-chrome":                "󰊯",
        "brave-browser":                "󰊯",
        "vivaldi":                      "󰊯",
        "opera":                        "󰊯",
        "epiphany":                     "󰊯",

        // ── Terminals ─────────────────────────────────────────────────────
        "kitty":                        "󰄛",
        "alacritty":                    "󰄛",
        "wezterm":                      "󰄛",
        "foot":                         "󰄛",
        "ghostty":                      "󰄛",
        "konsole":                      "󰄛",
        "xterm":                        "󰄛",

        // ── Editors / IDEs ────────────────────────────────────────────────
        "code":                         "󰨞",
        "code-oss":                     "󰨞",
        "vscodium":                     "󰨞",
        "neovim":                       "󰉿",
        "nvim":                         "󰉿",
        "vim":                          "󰉿",
        "helix":                        "󰉿",
        "zed":                          "󰉿",
        "jetbrains-idea":               "󰬺",
        "jetbrains-pycharm":            "󰬺",
        "android-studio":               "󰬺",

        // ── File Managers ─────────────────────────────────────────────────
        "thunar":                       "󰉋",
        "nautilus":                     "󰉋",
        "org.gnome.nautilus":           "󰉋",
        "org.kde.dolphin":              "󰉋",
        "nemo":                         "󰉋",
        "pcmanfm":                      "󰉋",

        // ── Chat / Social ─────────────────────────────────────────────────
        "discord":                      "󰙯",
        "vesktop":                      "󰙯",
        "vencord":                      "󰙯",
        "chrome_status_icon":           "󰙯",
        "telegram":                     "󰔁",
        "org.telegram.desktop":         "󰔁",
        "signal":                       "󰍡",
        "slack":                        "󰒱",
        "teams":                        "󰊻",
        "element":                      "󰍡",
        "fractal":                      "󰍡",

        // ── Music / Media ─────────────────────────────────────────────────
        "spotify":                      "󰓇",
        "cider":                        "󰝚",
        "apple-music":                  "󰝚",
        "strawberry":                   "󰝚",
        "rhythmbox":                    "󰝚",
        "clementine":                   "󰝚",
        "lollypop":                     "󰝚",
        "deadbeef":                     "󰝚",
        "vlc":                          "󰕼",
        "mpv":                          "󰕼",
        "celluloid":                    "󰕼",
        "obs":                          "󰑋",
        "obs-studio":                   "󰑋",

        // ── Gaming ────────────────────────────────────────────────────────
        "steam":                        "󰓓",
        "lutris":                       "󰮂",
        "heroic":                       "󰮂",
        "bottles":                      "󰮂",
        "minigalaxy":                   "󰮂",
        "unity":                        "󰚯",
        "unityhub":                     "󰚯",
        "cs2":                          "󰖺",
        "csgo":                         "󰖺",

        // ── Network ───────────────────────────────────────────────────────
        "nm-applet":                    "󰤨",
        "network manager":              "󰤨",
        "networkmanager":               "󰤨",
        "connman":                      "󰤨",
        "wicd":                         "󰤨",
        "openvpn":                      "󰦝",
        "nordvpn":                      "󰦝",
        "protonvpn":                    "󰦝",
        "mullvad":                      "󰦝",
        "expressvpn":                   "󰦝",
        "wireguard":                    "󰦝",
        "vpn":                          "󰦝",

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
        "satty":                    "󰄄",

        // ── Cloud / Sync ──────────────────────────────────────────────────
        "dropbox":                      "󰇣",
        "megasync":                     "󰇣",
        "insync":                       "󰇣",
        "nextcloud":                    "󰇣",
        "onedrive":                     "󰇣",
        "syncthing":                    "󰒖",

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

        // ── GPU / Display ─────────────────────────────────────────────────
        "nvidia-settings":              "󰾲",
        "supergfxctl":                  "󰾲",
        "optimus-manager":              "󰾲",
        "amdgpu":                       "󰾲",
        "corectrl":                     "󰾲",

        // ── Printers ──────────────────────────────────────────────────────
        "system-config-printer":        "󰐪",
        "cups":                         "󰐪",
        "print":                        "󰐪",

        // ── Input Method ──────────────────────────────────────────────────
        "ibus":                         "󰌌",
        "fcitx":                        "󰌌",
        "fcitx5":                       "󰌌",

        // ── Torrents / Downloads ──────────────────────────────────────────
        "qbittorrent":                  "󰇚",
        "deluge":                       "󰇚",
        "transmission":                 "󰇚",
        "filezilla":                    "󰇚",

        // ── Mail ──────────────────────────────────────────────────────────
        "mailspring":                   "󰇰",
        "thunderbird":                  "󰇰",
        "evolution":                    "󰇰",
        "mail":                         "󰇰",

        // ── Peripherals ───────────────────────────────────────────────────
        "solaar":                       "󰍽",
        "piper":                        "󰍽",
        "openrgb":                      "󰌁",
        "polychromatic":                "󰌁",
    })

    // ── Simple lookup — for Workspaces (app class string) ─────────────────
    // Exact match → substring match → first letter fallback
    function getIcon(appClass) {
        if (!appClass) return "󰍜"
        let key = appClass.toLowerCase().trim()

        if (iconMap[key]) return iconMap[key]

        for (let k in iconMap) {
            if (key.includes(k)) return iconMap[k]
        }

        return key.length > 0 ? key.substring(0, 1).toUpperCase() : "󰍜"
    }

    // ── Tray lookup — checks both title and id (SNI items expose both) ─────
    function getIconFromItem(item) {
        let title = (item.title || "").toLowerCase().trim()
        let id    = (item.id    || "").toLowerCase().trim()

        if (iconMap[title]) return iconMap[title]
        if (iconMap[id])    return iconMap[id]

        for (let k in iconMap) {
            if (title.includes(k) || id.includes(k)) return iconMap[k]
        }

        if (title.length > 0) return title.substring(0, 1).toUpperCase()
        if (id.length    > 0) return id.substring(0, 1).toUpperCase()
        return "󰍜"
    }
}
