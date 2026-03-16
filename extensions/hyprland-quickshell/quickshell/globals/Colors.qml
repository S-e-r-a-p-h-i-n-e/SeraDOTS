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
  readonly property color cursor: themeAdapter.special.cursor

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
        property color background: "#1C1C1E"
        property color foreground: "#F0CAC6"
      }

      property JsonObject colors: JsonObject {
        property color color0: "#434345"
        property color color1: "#432829"
        property color color2: "#5A3130"
        property color color3: "#713B37"
        property color color4: "#87443D"
        property color color5: "#9E4E44"
        property color color6: "#9E4E44"
        property color color7: "#E1ABA4"
        property color color8: "#9D7873"
        property color color9: "#5A3537"
        property color color10: "#784240"
        property color color11: "#964E49"
        property color color12: "#B55B52"
        property color color13: "#D3685B"
        property color color14: "#D3685B"
        property color color15: "#E1ABA4"
      }
    }
  }
}