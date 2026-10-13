local util = require("modules.util")
local section, safe, exec = util.section, util.safe, util.exec

section("gestures", function()

    -- 3 fingers left/right: switch workspace
    safe(hl.gesture, {
        fingers = 3,
        direction = "horizontal",
        action = "workspace",
    })

    -- 3 fingers up: fullscreen
    safe(hl.gesture, {
        fingers = 3,
        direction = "up",
        action = "fullscreen",
    })

    -- 3 fingers down: mute toggle
    safe(hl.gesture, {
        fingers = 3,
        direction = "down",
        action = function()
            exec("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")
        end,
    })

    -- 4 fingers: smooth, continuous volume control
    -- Move up to increase volume; move down to decrease it.
    local sensitivity = 5
    local movement = 0

    safe(hl.gesture, {
        fingers = 4,
        direction = "vertical",

        action = {
            start = function(e)
                movement = 0
            end,

            update = function(e)
                -- Up is negative delta.y; down is positive.
                movement = movement - e.delta.y

                -- Convert movement into small volume increments.
                local steps = math.floor(movement / sensitivity)

                if steps ~= 0 then
                    movement = movement - steps * sensitivity

                    if steps > 0 then
                        exec(
                            "wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ "
                            .. steps .. "%+"
                        )
                    else
                        exec(
                            "wpctl set-volume @DEFAULT_AUDIO_SINK@ "
                            .. math.abs(steps) .. "%-"
                        )
                    end
                end
            end,

            finish = function(e)
                movement = 0
            end,
        },
    })

end)