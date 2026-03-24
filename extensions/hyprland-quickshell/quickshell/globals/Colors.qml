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
        property color background: "#121218"
        property color foreground: "#B7DAF2"
      }

      property JsonObject colors: JsonObject {
        property color color0: "#3A3A40"
        property color color1: "#122E4C"
        property color color2: "#173E62"
        property color color3: "#1B4F78"
        property color color4: "#205F8E"
        property color color5: "#2570A4"
        property color color6: "#2570A4"
        property color color7: "#90C2E5"
        property color color8: "#6487A0"
        property color color9: "#183D65"
        property color color10: "#1E5382"
        property color color11: "#2469A0"
        property color color12: "#2B7FBD"
        property color color13: "#3195DB"
        property color color14: "#3195DB"
        property color color15: "#90C2E5"
      }
    }
  }
}