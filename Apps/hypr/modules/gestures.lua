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

    -- 4 fingers: smooth volume control
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
                movement = movement - e.delta.y

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

    -- 4 fingers: smooth brightness control
    -- Right increases brightness; left decreases it.
    local brightness_sensitivity = 5
    local brightness_movement = 0

    safe(hl.gesture, {
        fingers = 4,
        direction = "horizontal",

        action = {
            start = function(e)
                brightness_movement = 0
            end,

            update = function(e)
                brightness_movement = brightness_movement + e.delta.x

                local steps = math.floor(
                    brightness_movement / brightness_sensitivity
                )

                if steps ~= 0 then
                    brightness_movement =
                        brightness_movement - steps * brightness_sensitivity

                    if steps > 0 then
                        exec("brightnessctl set " .. steps .. "%+")
                    else
                        exec(
                            "brightnessctl set " .. math.abs(steps) .. "%-"
                        )
                    end
                end
            end,

            finish = function(e)
                brightness_movement = 0
            end,
        },
    })

end)
-- SUPER + 3 fingers vertical: browser-style zoom
-- up = zoom in, down = zoom out
local zoom = 1.0
local zoom_rate = 0.04   -- zoom ratio change per unit of finger movement
local zoom_max = 10.0

local function set_zoom(z)
    z = math.max(1.0, math.min(z, zoom_max))
    if z == zoom then return end   -- skip redundant updates at the limits
    zoom = z
    hl.config({ cursor = { zoom_factor = zoom } })
end

safe(hl.gesture, {
    fingers = 3,
    direction = "vertical",
    mods = "SUPER",

    action = {
        start = function(e) end,

        update = function(e)
            -- exponential: equal finger travel = equal zoom ratio
            set_zoom(zoom * math.exp(-e.delta.y * zoom_rate))
        end,

        finish = function(e) end,
    },
})

    -- SUPER + 3 fingers horizontal: color temperature (hyprsunset)
    -- right = cooler (towards 6000 K, neutral), left = warmer
    local temp_min = 1500
    local temp_max = 6000          -- hyprsunset's neutral / identity value
    local temp_rate = 10           -- Kelvin per unit of finger movement
    local temp_step = 50           -- only apply in 50 K steps
    local temp = temp_max
    local temp_sent = temp_max

    local function set_temp(t)
        temp = math.max(temp_min, math.min(t, temp_max))

        local snapped = math.floor(temp / temp_step + 0.5) * temp_step
        if snapped == temp_sent then return end   -- avoid spawning hyprctl needlessly
        temp_sent = snapped

        exec("hyprctl hyprsunset temperature " .. snapped)
    end

    safe(hl.gesture, {
        fingers = 3,
        direction = "horizontal",
        mods = "SUPER",

        action = {
            start = function(e) end,

            update = function(e)
                set_temp(temp + e.delta.x * temp_rate)
            end,

            finish = function(e) end,
        },
    })