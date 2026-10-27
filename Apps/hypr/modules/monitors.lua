
local section = require("modules.util").section

-- Laptop display
section("monitor", function()
    hl.monitor({
        output = "eDP-1",
        mode = "highrr",
        position = "0x0",
        scale = 1,
    })
end)

-- Virtual display (keep only if you need it)
section("monitor", function()
    hl.monitor({
        output = "Virtual-1",
        mode = "1280x720@60",
        position = "0x0",
        scale = 1,
    })
end)

-- External ultrawide
section("monitor", function()
    hl.monitor({
        output = "HDMI-A-1",
        mode = "3440x1440@74.98",
        position = "auto-up",
        scale = 1,
    })
end)

-- Default workspace layout
section("workspace rules", function()
    for i = 1, 4 do
        hl.workspace_rule({ workspace = tostring(i), monitor = "HDMI-A-1" })
    end
    for i = 5, 10 do
        hl.workspace_rule({ workspace = tostring(i), monitor = "eDP-1" })
    end
end)
