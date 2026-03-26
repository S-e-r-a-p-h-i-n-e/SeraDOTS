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
        property color background: "#121415"
        property color foreground: "#AEDEDA"
      }

      property JsonObject colors: JsonObject {
        property color color0: "#393C3D"
        property color color1: "#093332"
        property color color2: "#0B4542"
        property color color3: "#0D5651"
        property color color4: "#0F6860"
        property color color5: "#117970"
        property color color6: "#117970"
        property color color7: "#83C8C2"
        property color color8: "#5B8C87"
        property color color9: "#0C4543"
        property color color10: "#0F5C57"
        property color color11: "#11736C"
        property color color12: "#148B80"
        property color color13: "#17A295"
        property color color14: "#17A295"
        property color color15: "#83C8C2"
      }
    }
  }
}