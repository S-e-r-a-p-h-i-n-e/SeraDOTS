-- Not loaded by hyprland.lua (same as the original .conf). Swap the require in
-- hyprland.lua to use it. The original file defined two `animations` blocks;
-- the second is identical in effect to animation-slide, so both are kept in order.
hl.config({ animations = { enabled = true } })

local function bezier(name, p1, p2)
    hl.curve(name, { type = "bezier", points = { p1, p2 } })
end

local function anim(leaf, speed, curve, style)
    hl.animation({ leaf = leaf, enabled = true, speed = speed, bezier = curve, style = style })
end

-- Block 1
bezier("easeOutQuint",   { 0.23, 1 },    { 0.32, 1 })
bezier("easeInOutCubic", { 0.65, 0.05 }, { 0.36, 1 })
bezier("linear",         { 0, 0 },       { 1, 1 })
bezier("almostLinear",   { 0.5, 0.5 },   { 0.75, 1.0 })
bezier("quick",          { 0.15, 0 },    { 0.1, 1 })

anim("global",           10,   "default")
anim("border",           5.39, "easeOutQuint")
anim("windows",          4.79, "easeOutQuint")
anim("windowsIn",        4.1,  "easeOutQuint", "popin 87%")
anim("windowsOut",       1.49, "linear",       "popin 87%")
anim("fadeIn",           1.73, "almostLinear")
anim("fadeOut",          1.46, "almostLinear")
anim("fade",             3.03, "quick")
anim("layers",           3.81, "easeOutQuint")
anim("layersIn",         4,    "easeOutQuint", "fade")
anim("layersOut",        1.5,  "linear",       "fade")
anim("fadeLayersIn",     1.79, "almostLinear")
anim("fadeLayersOut",    1.39, "almostLinear")
anim("workspaces",       1.94, "almostLinear", "fade")
anim("workspacesIn",     1.21, "almostLinear", "fade")
anim("workspacesOut",    1.94, "almostLinear", "fade")

-- Block 2
bezier("wind",   { 0.05, 0.9 }, { 0.1, 1.05 })
bezier("winIn",  { 0.1, 1.1 },  { 0.1, 1.1 })
bezier("winOut", { 0.3, -0.3 }, { 0, 1 })
bezier("liner",  { 1, 1 },      { 1, 1 })

anim("windows",     6,  "wind",   "slide")
anim("windowsIn",   6,  "winIn",  "slide")
anim("windowsOut",  5,  "winOut", "slide")
anim("windowsMove", 5,  "wind",   "slide")
anim("border",      1,  "liner")
anim("borderangle", 30, "liner",  "loop")
anim("fade",        10, "default")
anim("workspaces",  5,  "wind")
anim("layers",      6,  "wind",   "popin 90%")
anim("layersIn",    6,  "winIn",  "popin 90%")
anim("layersOut",   5,  "winOut", "popin 90%")
