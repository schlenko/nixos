local util = require("modules.util")
local section, safe, exec = util.section, util.safe, util.exec

section("gestures", function()
    safe(hl.gesture, { fingers = 3, direction = "horizontal", action = "workspace" })

    safe(hl.gesture, {
        fingers = 3, direction = "up", action = "cursorZoom",
        zoom_level = "1.5", mode = "mult",
    })

    safe(hl.gesture, {
        fingers = 3, direction = "down", action = "cursorZoom",
        zoom_level = "1.5", mode = "mult",
    })

    safe(hl.gesture, {
        fingers = 4, direction = "up",
        action = function()
            exec("sh ~/.config/hypr/scripts/OverviewToggle.sh")
        end,
    })

    safe(hl.gesture, { fingers = 4, direction = "down", action = "float" })
end)