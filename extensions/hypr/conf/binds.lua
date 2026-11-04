-- --- Keybindings ---
local mainMod = "SUPER"

-- Applications
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd("kitty"))
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd("gram"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("dolphin"))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("librewolf"))
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd("spotify"))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("vesktop"))

-- Window Management
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind("ALT + F4", hl.dsp.window.close())
hl.bind(mainMod .. " + DELETE", hl.dsp.exit())
hl.bind(mainMod .. " + W", hl.dsp.window.float())
hl.bind("ALT + RETURN", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.pin())
hl.bind(mainMod .. " + SHIFT + O", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + O", hl.dsp.window.set_prop({ prop = "opaque", value = "toggle" }))

-- Custom Scripts
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd("qs ipc call launcher toggle"))
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd("qs ipc call wallpaper toggle"))
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.exec_cmd("qs ipc call clipboard toggle"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("qs ipc call theming toggle"))
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd("qs ipc call shell hardReload"))
hl.bind(mainMod .. " + SHIFT + PERIOD", hl.dsp.exec_cmd("qs ipc call emoji toggle"))
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd(
    [[notify-send "Switched Layout To:" "$(hyprctl -j devices | jq -r '.keyboards[] | select(.main == true) | .active_keymap' | head -n 1)"]]
))
-- NOTE: The above command uses `jq` to parse the output of `hyprctl` and extract the active keyboard layout.
--       The handler that changes the layout is the XKB option in input.lua (grp:win_space_toggle).

-- Hardware Controls (locked = works even when the screen is locked)
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("pamixer -t"),                { locked = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("pamixer -d 5"),              { locked = true })
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("pamixer -i 5"),              { locked = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl set +5%"),     { locked = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"),     { locked = true })
hl.bind("XF86AudioPlay",         hl.dsp.exec_cmd("playerctl play-pause"),      { locked = true })
hl.bind("XF86AudioNext",         hl.dsp.exec_cmd("playerctl next"),            { locked = true })
hl.bind("XF86AudioPrev",         hl.dsp.exec_cmd("playerctl previous"),        { locked = true })

-- Screenshots
hl.bind(mainMod .. " + P",          hl.dsp.exec_cmd("grim - | satty --filename -"))
hl.bind(mainMod .. " + CTRL + P",   hl.dsp.exec_cmd([[grim -g "$(slurp)" - | satty --filename -]]))
hl.bind(mainMod .. " + SHIFT + P",  hl.dsp.exec_cmd([[grim ~/Pictures/Screenshot-$(date +'%Y-%m-%d-%H%M%S').png]]))

-- Navigation
hl.bind(mainMod .. " + Left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + Right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + Up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + Down",  hl.dsp.focus({ direction = "down" }))

-- Workspace switching (1-10) and moving windows to workspaces (key 0 = workspace 10)
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i, follow = true }))
end

-- Resizing (Continuous)
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.resize({ x = 30,  y = 0,   relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.resize({ x = -30, y = 0,   relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.resize({ x = 0,   y = -30, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.resize({ x = 0,   y = 30,  relative = true }), { repeating = true })

-- Mouse Binds
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
