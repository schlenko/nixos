local util = require("modules.util")
local section, safe, exec = util.section, util.safe, util.exec

section("gestures", function()
    -- 3 fingers left/right: switch workspace (continuous, follows your fingers)
    safe(hl.gesture, { fingers = 3, direction = "horizontal", action = "workspace" })

    -- 3 fingers up: fullscreen
    safe(hl.gesture, { fingers = 3, direction = "up", action = "fullscreen" })

    -- 3 fingers down: mute toggle
    safe(hl.gesture, {
        fingers = 3, direction = "down",
        action = function()
            exec("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")
        end,
    })

    -- 4 fingers up/down: volume (one step per swipe)
    safe(hl.gesture, {
        fingers = 4, direction = "up",
        action = function()
            exec("wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+")
        end,
    })
    safe(hl.gesture, {
        fingers = 4, direction = "down",
        action = function()
            exec("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-")
        end,
    })

    -- 4 finger pinch in: close window
    safe(hl.gesture, { fingers = 4, direction = "pinchin", action = "close" })
end)