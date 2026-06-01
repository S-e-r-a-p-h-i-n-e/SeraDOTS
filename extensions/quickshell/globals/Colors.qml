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
        property color background: "#F2FFFF"
        property color foreground: "#0B0612"
      }

      property JsonObject colors: JsonObject {
        property color color0: "#F2FFFF"
        property color color1: "#246481"
        property color color2: "#30627D"
        property color color3: "#284C65"
        property color color4: "#21364D"
        property color color5: "#192036"
        property color color6: "#120A1E"
        property color color7: "#0B0612"
        property color color8: "#3A84A0"
        property color color9: "#3086AC"
        property color color10: "#3F82A6"
        property color color11: "#366586"
        property color color12: "#2C4867"
        property color color13: "#222B48"
        property color color14: "#180E28"
        property color color15: "#040206"
      }
    }
  }
}