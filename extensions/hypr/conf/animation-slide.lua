hl.config({ animations = { enabled = true } })

local function bezier(name, p1, p2)
    hl.curve(name, { type = "bezier", points = { p1, p2 } })
end

local function anim(leaf, speed, curve, style)
    hl.animation({ leaf = leaf, enabled = true, speed = speed, bezier = curve, style = style })
end

bezier("wind",    { 0.05, 0.9 }, { 0.1, 1.05 })
bezier("winIn",   { 0.1, 1.1 },  { 0.1, 1.1 })
bezier("winOut",  { 0.3, -0.3 }, { 0, 1 })
bezier("liner",   { 1, 1 },      { 1, 1 })

anim("windows",     6,  "wind",   "slide")
anim("windowsIn",   6,  "winIn",  "slide")
anim("windowsOut",  5,  "winOut", "slide")
anim("windowsMove", 5,  "wind",   "slide")
anim("border",      1,  "liner")
anim("borderangle", 30, "liner",  "loop")
anim("layers",      6,  "wind",   "popin 90%")
anim("layersIn",    6,  "winIn",  "popin 90%")
anim("layersOut",   5,  "winOut", "popin 90%")
anim("workspaces",  5,  "wind")

bezier("almostLinear", { 0.5, 0.5 }, { 0.75, 1.0 })
anim("fadeIn",  1.73, "almostLinear")
anim("fadeOut", 1.46, "almostLinear")
anim("fade",    3.03, "almostLinear")
