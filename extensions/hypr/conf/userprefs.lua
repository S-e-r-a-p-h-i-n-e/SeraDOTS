-- Quickshell panel: blur, and don't ignore any alpha
hl.layer_rule({
    match = { namespace = "quickshell-panel$" },
    blur = true,
    ignore_alpha = 0,
})

-- Bind the OpenTabletDriver virtual tablet to the monitor
hl.device({
    name = "opentabletdriver-virtual-artist-tablet",
    output = "HDMI-A-1",
})

hl.on("hyprland.start", function()
    hl.exec_cmd("systemctl --user start opentabletdriver")
    hl.exec_cmd("mprisence")
end)
