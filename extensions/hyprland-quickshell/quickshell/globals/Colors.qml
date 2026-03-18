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
        property color background: "#1C1A1B"
        property color foreground: "#EAD2D3"
      }

      property JsonObject colors: JsonObject {
        property color color0: "#434142"
        property color color1: "#422C2E"
        property color color2: "#56383B"
        property color color3: "#6A4547"
        property color color4: "#7F5254"
        property color color5: "#935F61"
        property color color6: "#935F61"
        property color color7: "#D9B6B8"
        property color color8: "#987F80"
        property color color9: "#583A3E"
        property color color10: "#734B4E"
        property color color11: "#8E5C5F"
        property color color12: "#A96D70"
        property color color13: "#C47E81"
        property color color14: "#C47E81"
        property color color15: "#D9B6B8"
      }
    }
  }
}