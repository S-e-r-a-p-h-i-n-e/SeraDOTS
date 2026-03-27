// quickshell/shared/Colors.qml
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
  id: root

  property alias themeAdapter: themeAdapter

  readonly property color background: themeAdapter.special.background
  readonly property color foreground: themeAdapter.special.foreground
  readonly property color cursor: "#FFFFFF"

  readonly property color color0: themeAdapter.colors.color0
  readonly property color color1: themeAdapter.colors.color1
  readonly property color color2: themeAdapter.colors.color2
  readonly property color color3: themeAdapter.colors.color3
  readonly property color color4: themeAdapter.colors.color4
  readonly property color color5: themeAdapter.colors.color5
  readonly property color color6: themeAdapter.colors.color6
  readonly property color color7: themeAdapter.colors.color7
  readonly property color color8: themeAdapter.colors.color8
  readonly property color color9: themeAdapter.colors.color9
  readonly property color color10: themeAdapter.colors.color10
  readonly property color color11: themeAdapter.colors.color11
  readonly property color color12: themeAdapter.colors.color12
  readonly property color color13: themeAdapter.colors.color13
  readonly property color color14: themeAdapter.colors.color14
  readonly property color color15: themeAdapter.colors.color15

  FileView {
    id: themeFile
    adapter: JsonAdapter {
      id: themeAdapter

      property JsonObject special: JsonObject {
        property color background: "#16171B"
        property color foreground: "#D9DBE2"
      }

      property JsonObject colors: JsonObject {
        property color color0: "#3D3E43"
        property color color1: "#293242"
        property color color2: "#3A4252"
        property color color3: "#4B5262"
        property color color4: "#5C6372"
        property color color5: "#6D7382"
        property color color6: "#6D7382"
        property color color7: "#C0C4CE"
        property color color8: "#868990"
        property color color9: "#374258"
        property color color10: "#4D586D"
        property color color11: "#646E82"
        property color color12: "#7B8398"
        property color color13: "#9299AD"
        property color color14: "#9299AD"
        property color color15: "#C0C4CE"
      }
    }
  }
}