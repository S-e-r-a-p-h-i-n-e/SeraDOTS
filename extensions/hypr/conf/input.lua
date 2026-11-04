-- --- Input Devices ---
hl.config({
    input = {
        -- Keyboard
        kb_layout = "us,se,ru",
        kb_options = "grp:win_space_toggle",

        -- Mouse
        -- follow_mouse = 1,
        accel_profile = "flat",
        -- sensitivity = -0.5,

        -- Touchpad
        touchpad = {
            natural_scroll = false,
            disable_while_typing = true,
            tap_to_click = true,
            scroll_factor = 1.0,
        },
    },
})
