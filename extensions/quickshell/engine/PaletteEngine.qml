// engine/PaletteEngine.qml
// Internal palette engine — no external theming tools.
// Uses ImageMagick to extract dominant colors from the wallpaper,
// assigns them to terminal color roles by hue/luminance, and writes
// ~/.cache/quickshell/palette.json which Colors.qml watches.
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.globals

Singleton {
    id: root

    readonly property string outPath: Quickshell.env("HOME") + "/.cache/quickshell/palette.json"
    property bool running:   false
    property bool available: false   // set after startup probe

    // ── Startup probe: check magick is installed ───────────────────────────
    Process {
        id: probe
        command: ["which", "magick"]
        running: true
        onExited: (code, status) => { root.available = (code === 0) }
        stdout: StdioCollector {}
        stderr: StdioCollector {}
    }

    // Expose a human-readable reason for the UI
    readonly property string unavailableReason: available ? "" : "requires ImageMagick (magick)"

    function generate(wallpaperPath) {
        if (!wallpaperPath || wallpaperPath === "") return
        extractor.videoMode = isVideo(wallpaperPath)
        extractor.src = wallpaperPath
        extractor.running = true
        root.running = true
    }

    function isVideo(path) {
        let ext = path.substring(path.lastIndexOf('.') + 1).toLowerCase()
        return ["mp4","webm","mkv","mov","avi"].indexOf(ext) !== -1
    }

    // ── Step 1: extract colors via ImageMagick ─────────────────────────────
    Process {
        id: extractor
        property string src: ""
        property bool videoMode: false

        // Videos: try extracting frame at 10s, fall back to 5s, then frame 1.
        // Uses a temp file so ffmpeg and magick aren't piped together —
        // this avoids sh -c misinterpreting the > in magick's -resize flag.
        // Images: plain array, no shell involved.
        command: videoMode
            ? ["sh", "-c",
               `TMP=$(mktemp /tmp/qs_XXXXXX.png) && ` +
               `(ffmpeg -y -ss 10 -i ${shellQuote(src)} -frames:v 1 "$TMP" 2>/dev/null || ` +
               ` ffmpeg -y -ss 5  -i ${shellQuote(src)} -frames:v 1 "$TMP" 2>/dev/null || ` +
               ` ffmpeg -y        -i ${shellQuote(src)} -frames:v 1 "$TMP" 2>/dev/null) && ` +
               `magick "$TMP" -resize 150x150 +dither -colors 16 -unique-colors txt:- ; ` +
               `rm -f "$TMP"`]
            : ["magick", src, "-resize", "200x200>",
               "+dither", "-colors", "16", "-unique-colors", "txt:-"]
        stdout: StdioCollector {
            onStreamFinished: {
                let colors = parseColors(this.text)
                if (colors.length < 2) {
                    console.warn("[PaletteEngine] Not enough colors extracted:", colors.length)
                    root.running = false
                    return
                }
                let palette = buildPalette(colors)
                writePalette(palette)
            }
        }
        stderr: StdioCollector {
            onStreamFinished: {
                if (this.text.trim() !== "")
                    console.warn("[PaletteEngine] magick:", this.text.trim())
            }
        }
        onRunningChanged: { if (!running) root.running = false }
    }

    // ── Step 2: parse hex strings from magick txt output ──────────────────
    // Output format per line: "0,0: (14849,12545,18247)  #3A3148  srgb(...)"
    function parseColors(text) {
        let colors = []
        let lines = text.split('\n')
        for (let i = 0; i < lines.length; i++) {
            // ImageMagick 7 emits 8-char hex (#RRGGBBAA) — grab only the RGB part
            let m = lines[i].match(/#([0-9A-Fa-f]{6})/)
            if (m) colors.push("#" + m[1].toUpperCase())
        }
        return colors
    }

    // Safely wrap a path for use in sh -c commands
    function shellQuote(s) { return "'" + s.replace(/'/g, "'\\''") + "'" }

    // ── Color math helpers ─────────────────────────────────────────────────
    function hexToRgb(hex) {
        return {
            r: parseInt(hex.slice(1,3), 16) / 255,
            g: parseInt(hex.slice(3,5), 16) / 255,
            b: parseInt(hex.slice(5,7), 16) / 255
        }
    }

    function luminance(hex) {
        let c = hexToRgb(hex)
        return 0.2126 * c.r + 0.7152 * c.g + 0.0722 * c.b
    }

    function toHsl(hex) {
        let c = hexToRgb(hex)
        let max = Math.max(c.r, c.g, c.b)
        let min = Math.min(c.r, c.g, c.b)
        let d = max - min
        let l = (max + min) / 2
        let s = d === 0 ? 0 : d / (l > 0.5 ? 2 - max - min : max + min)
        let h = 0
        if (d !== 0) {
            switch (max) {
                case c.r: h = ((c.g - c.b) / d + (c.g < c.b ? 6 : 0)); break
                case c.g: h = ((c.b - c.r) / d + 2); break
                case c.b: h = ((c.r - c.g) / d + 4); break
            }
            h = h / 6 * 360
        }
        return { h, s, l }
    }

    function fromHsl(h, s, l) {
        h = ((h % 360) + 360) % 360 / 360
        let r, g, b
        if (s === 0) {
            r = g = b = l
        } else {
            let q = l < 0.5 ? l * (1 + s) : l + s - l * s
            let p = 2 * l - q
            // hue2rgb inlined — nested function declarations are unreliable in QML JS
            let tr = h + 1/3, tg = h, tb = h - 1/3
            tr = tr < 0 ? tr+1 : tr > 1 ? tr-1 : tr
            tg = tg < 0 ? tg+1 : tg > 1 ? tg-1 : tg
            tb = tb < 0 ? tb+1 : tb > 1 ? tb-1 : tb
            r = tr < 1/6 ? p+(q-p)*6*tr : tr < 0.5 ? q : tr < 2/3 ? p+(q-p)*(2/3-tr)*6 : p
            g = tg < 1/6 ? p+(q-p)*6*tg : tg < 0.5 ? q : tg < 2/3 ? p+(q-p)*(2/3-tg)*6 : p
            b = tb < 1/6 ? p+(q-p)*6*tb : tb < 0.5 ? q : tb < 2/3 ? p+(q-p)*(2/3-tb)*6 : p
        }
        function ch(x) { let v = Math.round(x*255).toString(16); return v.length===1?"0"+v:v }
        return "#" + ch(r) + ch(g) + ch(b)
    }

    function nudgeLightness(hex, delta) {
        let hsl = toHsl(hex)
        return fromHsl(hsl.h, hsl.s, Math.max(0.05, Math.min(0.95, hsl.l + delta)))
    }

    function hueDist(a, b) {
        let d = Math.abs(a - b) % 360
        return d > 180 ? 360 - d : d
    }

    // ── Contrast helpers ───────────────────────────────────────────────────
    function contrastRatio(hexA, hexB) {
        let la = luminance(hexA), lb = luminance(hexB)
        return (Math.max(la, lb) + 0.05) / (Math.min(la, lb) + 0.05)
    }

    // Push `fg` lighter or darker until it achieves `minRatio` against `bg`.
    function ensureContrast(fg, bg, minRatio) {
        if (contrastRatio(fg, bg) >= minRatio) return fg
        let hsl = toHsl(fg)
        let bgL = luminance(bg)
        let step = bgL < 0.5 ? 0.04 : -0.04   // dark bg → push light; light bg → push dark
        for (let i = 0; i < 20; i++) {
            hsl.l = Math.max(0.05, Math.min(0.95, hsl.l + step))
            fg = fromHsl(hsl.h, hsl.s, hsl.l)
            if (contrastRatio(fg, bg) >= minRatio) break
        }
        return fg
    }

    // Ensure a color has at least `minSat` saturation, keeping its hue and
    // clamping lightness to a visible range so it doesn't become white/black.
    function ensureSaturation(hex, minSat) {
        let hsl = toHsl(hex)
        if (hsl.s >= minSat) return hex
        hsl.s = minSat
        hsl.l = Math.max(0.35, Math.min(0.70, hsl.l))
        return fromHsl(hsl.h, hsl.s, hsl.l)
    }

    // ── Step 3: assign colors to terminal roles ────────────────────────────
    //
    // After basic luminance-based assignment, contrast ratios are enforced:
    //   foreground vs background  ≥ 5.5  (text/active icons readable on bar)
    //   color7 vs background      ≥ 3.0  (inactive icons visible)
    //   color0 vs background      ≥ 1.5  (pill bg distinguishable from bar)
    //   background vs color0      ≥ 1.5  (icon text readable on pill)
    //   color8 vs background      ≥ 3.0  (shared secondary-text color —
    //                                      subtitles, timers, chip labels)
    //   color8 vs color0          ≥ 3.0  (same text, drawn directly on
    //                                      color0 cards in Dashboard.qml)
    // Accent colors (color1–6) get a minimum saturation of 0.35 so they
    // don't collapse into the same grey as the surface colors.
    //   color1 = red     (~  0°)
    //   color2 = green   (~120°)
    //   color3 = yellow  (~ 60°)
    //   color4 = blue    (~240°)
    //   color5 = magenta (~300°)
    //   color6 = cyan    (~180°)
    //
    // - Sort by luminance; darkest → bg/color0, brightest → fg/color15
    // - Remaining pool greedily assigned to closest hue target
    // - Bright variants (color9-14) = accent lightened by 12%
    // - If pool runs dry, synthesise from hue-shifted bg

    function buildPalette(colors) {
        let sorted = colors.slice().sort((a, b) => luminance(a) - luminance(b))
        let n = sorted.length

        let bg  = sorted[0]
        let fg  = sorted[n - 1]
        let c0  = n > 1 ? sorted[1]     : nudgeLightness(bg,  0.08)
        let c7  = n > 2 ? sorted[n - 2] : nudgeLightness(fg, -0.10)
        let c15 = nudgeLightness(fg, 0.05)

        let mids = sorted.slice(2, n - 1)

        // Cursor: most saturated mid-tone
        let cursor = mids.slice().sort((a, b) => toHsl(b).s - toHsl(a).s)[0] || fg

        let targets = [
            { hue: 0,   key: "color1" },
            { hue: 120, key: "color2" },
            { hue: 60,  key: "color3" },
            { hue: 240, key: "color4" },
            { hue: 300, key: "color5" },
            { hue: 180, key: "color6" },
        ]

        let accents = {}
        let pool = mids.slice()

        for (let i = 0; i < targets.length; i++) {
            let t = targets[i]
            let best = null, bestScore = Infinity
            for (let j = 0; j < pool.length; j++) {
                let hsl = toHsl(pool[j])
                let score = hueDist(hsl.h, t.hue) + (1 - hsl.s) * 30
                if (score < bestScore) { bestScore = score; best = pool[j] }
            }
            if (best) {
                pool.splice(pool.indexOf(best), 1)
            } else {
                best = fromHsl(t.hue, 0.55, 0.55)
            }
            // Ensure accents are saturated enough to be visible against surface colors
            accents[t.key] = ensureSaturation(best, 0.35)
        }

        // Enforce contrast so text/icons don't blend into their backgrounds
        fg  = ensureContrast(fg,  bg, 5.5)   // text/active icons on bar
        c7  = ensureContrast(c7,  bg, 3.0)   // inactive icons on bar
        c0  = ensureContrast(c0,  bg, 1.5)   // pill bg vs bar bg
        c15 = ensureContrast(c15, bg, 6.0)   // bright white — always near-white
        // Derived from c0 *after* c0's own correction, then checked in its
        // own right — c8 is the shared secondary-text color across nearly
        // every panel (subtitles, timers, "CPU"/"RAM" labels, CCToggle
        // labels), so an unresolved "close to bg" c0 must not carry through.
        // c8 also sits as text directly on top of dashboard/notification
        // cards, which use c0 as their fill (Dashboard.qml) — a small
        // lightness nudge off c0 is fine as a divider line (low opacity)
        // but not enough as solid text on that same c0 surface, so contrast
        // against c0 is enforced too, not just against bg.
        let c8 = nudgeLightness(c0, 0.12)
        c8 = ensureContrast(c8, bg, 3.0)
        c8 = ensureContrast(c8, c0, 3.0)

        return {
            background: bg,   foreground: fg,   cursor,
            color0:  c0,      color1:  accents.color1,
            color2:  accents.color2,  color3:  accents.color3,
            color4:  accents.color4,  color5:  accents.color5,
            color6:  accents.color6,  color7:  c7,
            color8:  c8,
            color9:  nudgeLightness(accents.color1,  0.12),
            color10: nudgeLightness(accents.color2,  0.12),
            color11: nudgeLightness(accents.color3,  0.12),
            color12: nudgeLightness(accents.color4,  0.12),
            color13: nudgeLightness(accents.color5,  0.12),
            color14: nudgeLightness(accents.color6,  0.12),
            color15: c15
        }
    }

    signal paletteReady()

    // ── Step 4: write palette.json and reload Colors ───────────────────────
    // Uses a Process (not execDetached) so we know exactly when the write lands
    // and can call Colors.reload() — no timers, no guessing.
    // Direct write (no tmp→mv) so inotify keeps tracking the same inode.
    Process {
        id: writer
        property string payload: ""
        command: ["sh", "-c",
            `mkdir -p "$(dirname '${root.outPath}')" && ` +
            `printf '%s' '${writer.payload}' > '${root.outPath}'`
        ]
        onExited: Colors.reload()
        stderr: StdioCollector {
            onStreamFinished: {
                if (this.text.trim() !== "")
                    console.warn("[PaletteEngine] write error:", this.text.trim())
            }
        }
    }

    function writePalette(p) {
        let json = JSON.stringify({
            special: {
                background: p.background,
                foreground: p.foreground,
                cursor:     p.cursor
            },
            colors: {
                color0:  p.color0,  color1:  p.color1,
                color2:  p.color2,  color3:  p.color3,
                color4:  p.color4,  color5:  p.color5,
                color6:  p.color6,  color7:  p.color7,
                color8:  p.color8,  color9:  p.color9,
                color10: p.color10, color11: p.color11,
                color12: p.color12, color13: p.color13,
                color14: p.color14, color15: p.color15
            }
        }, null, 2)
        writer.payload = json.replace(/'/g, "'\\''")
        writer.running = true
    }
}
