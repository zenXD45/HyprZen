hl.config({
    decoration = {
        rounding = 18,
        active_opacity = 1.0,
        inactive_opacity = inactive_opacity,
        fullscreen_opacity = 1.0,
        shadow = {
            enabled = true,
            range = 20,
            render_power = 3,
            color = "rgba(00000066)",
        },
        blur = {
            enabled = true,
            size = 4,
            passes = 4,
            ignore_opacity = true,
            noise = 0.08,
            contrast = 1.5,
            xray = false,
            new_optimizations = true,
        },
    },
})
