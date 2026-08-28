// quickshell/shared/Colors.qml
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.globals

Singleton {
  id: root

  property alias themeAdapter: themeAdapter

  readonly property color background: themeAdapter.special.background
  readonly property color foreground: themeAdapter.special.foreground
  readonly property color cursor:     themeAdapter.special.cursor

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

  readonly property string home:          Quickshell.env("HOME")
  readonly property string wallustPath:   home + "/.cache/quickshell/wallust-colors.json"
  readonly property string internalPath:  home + "/.cache/quickshell/palette.json"
  readonly property string palettesDir:   home + "/.config/quickshell/palettes"

  // "wallust" and "internal" are the two dynamic, wallpaper-derived
  // sources. Anything else in Config.paletteSource is read as a static
  // file — palettes/<name>.json — so new palettes drop in with no QML
  // change, just a new file in that folder.
  function _resolvePath() {
    switch (Config.paletteSource) {
      case "wallust":  return root.wallustPath
      case "internal": return root.internalPath
      default:         return root.palettesDir + "/" + Config.paletteSource + ".json"
    }
  }

  function reload() { themeFile.reload() }

  FileView {
    id: themeFile
    // Never set path to "" — that does not reset the adapter, it just
    // stops watching, so _resolvePath() always returns a concrete path.
    path: root._resolvePath()
    adapter: JsonAdapter {
      id: themeAdapter

      property JsonObject special: JsonObject {
        property color background: "#16141A"
        property color foreground: "#C6DFF1"
        property color cursor:     "#FFFFFF"
      }

      property JsonObject colors: JsonObject {
        property color color0: "#3D3B41"
        property color color1: "#22314C"
        property color color2: "#2B4361"
        property color color3: "#345676"
        property color color4: "#3D688B"
        property color color5: "#467AA0"
        property color color6: "#467AA1"
        property color color7: "#A6C9E2"
        property color color8: "#748C9E"
        property color color9: "#2D4265"
        property color color10: "#395A81"
        property color color11: "#45729D"
        property color color12: "#518BBA"
        property color color13: "#5DA3D6"
        property color color14: "#5DA3D6"
        property color color15: "#A6C9E2"
      }
    }
  }
}
