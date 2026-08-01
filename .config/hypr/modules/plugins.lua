-- HyprZen — Plugin Configuration (scrolloverview)
-- The plugin is loaded at startup via "hyprpm reload -n" in exec.lua.
-- This file only sets plugin options; it will silently skip if the plugin
-- is not installed (pcall catches the unknown-key errors).

pcall(function()
    hl.config({
        plugin = {
            scrolloverview = {
                gesture_distance = 300,
                scale = 0.5,
                workspace_gap = 100,
                layout = "vertical",
                wallpaper = 0,
                blur = false,
                shadow = {
                    enabled = false,
                    range = 50,
                    render_power = 3,
                    color = 0xee1a1a1a,
                },
            },
        },
    })
end)
