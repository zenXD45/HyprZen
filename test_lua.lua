hl = {
    config = function(t) end,
    bind = function(...) end,
    env = function(...) end,
    device = function(...) end,
    window_rule = function(...) end,
    layer_rule = function(...) end,
    monitor = function(...) end,
    on = function(...) end,
    exec_cmd = function(...) end,
    dsp = {
        exec_cmd = function(...) end,
        window = {
            close = function(...) end,
            fullscreen = function(...) end,
            float = function(...) end,
            pseudo = function(...) end,
            set_prop = function(...) end,
            drag = function(...) end,
            resize = function(...) end,
            move = function(...) end,
        },
        focus = function(...) end,
        workspace = {
            toggle_special = function(...) end,
        },
        exit = function(...) end,
    }
}
-- mock package.path to find modules and themes
package.path = "./.config/hypr/?.lua;" .. package.path
require("hyprland")
print("Success!")
