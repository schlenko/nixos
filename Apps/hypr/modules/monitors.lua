local section = require("modules.util").section

section("monitor", function()
    hl.monitor({
        output = "eDP-1",
        mode = "preferred",
        position = "0x0",
        scale = 1,
    })
end)

section("monitor", function()
    hl.monitor({
        output = "Virtual-1",
        mode = "1280x720@60",
        position = "0x0",
        scale = 1,
    })
end)


section("workspace rules", function()
    hl.workspace_rule({
        workspace = "1",
        monitor = "eDP-1",
        layout = "dwindle",
    })
end)
