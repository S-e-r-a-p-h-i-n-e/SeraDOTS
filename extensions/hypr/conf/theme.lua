local c = require("conf.colors")

-----------------------
--- LOOK AND FEEL   ---
-----------------------

hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 10,
        border_size = 2,
        col = {
            active_border = c.color13,
            inactive_border = c.inactive,
        },
        -- Resize windows by clicking and dragging on borders and gaps
        resize_on_border = true,
        -- See the Tearing page on the wiki before turning this on
        allow_tearing = false,
        layout = "dwindle",
        snap = {
            enabled = true,
            window_gap = 10,       -- pixels distance to snap to other windows
            monitor_gap = 10,      -- pixels distance to snap to monitor edges/corners
            border_overlap = false, -- true = borders overlap when snapped
            respect_gaps = true,   -- true = snapped windows respect gaps_in/out
        },
    },

    decoration = {
        rounding = 15,
        rounding_power = 2,

        -- Transparency of focused and unfocused windows
        active_opacity = 0.8,
        inactive_opacity = 0.3,

        shadow = {
            enabled = true,
            range = 6,
            render_power = 3,
            color = c.color0,
        },

        blur = {
            enabled = true,
            size = 4,
            passes = 2,
            contrast = 1,
            brightness = 1,
            vibrancy = 1,
        },
    },

    master = {
        new_status = "master",
    },
})
