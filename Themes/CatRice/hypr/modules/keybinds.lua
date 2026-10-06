local section = require("modules.util").section
local vars = require("modules.vars")

local mainMod = vars.mainMod

section("binds.apps", function()
    hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(vars.terminal),
        { description = "Open terminal" })

   hl.bind(mainMod .. " + Space", hl.dsp.exec_cmd("pkill rofi || " .. vars.launcher),
    { description = "App launcher" })
    

    hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("xdg-open https://"),
        { description = "Open default browser" })

    hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock"),
    { description = "Lock screen" })

end)

section("binds.window", function()
    hl.bind(mainMod .. " + Q", hl.dsp.window.close(),
        { description = "Close window" })

    hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }),
        { description = "Toggle floating" })

    hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen(),
        { description = "Toggle fullscreen" })


    hl.bind(mainMod .. " + LEFT",  hl.dsp.focus({ direction = "left" }),  { description = "Focus left" })
    hl.bind(mainMod .. " + RIGHT", hl.dsp.focus({ direction = "right" }), { description = "Focus right" })
    hl.bind(mainMod .. " + UP",    hl.dsp.focus({ direction = "up" }),    { description = "Focus up" })
    hl.bind(mainMod .. " + DOWN",  hl.dsp.focus({ direction = "down" }),  { description = "Focus down" })
end)

section("binds.mouse", function()
    hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),
        { description = "Move window", mouse = true })

    hl.bind(mainMod .. " + SHIFT + mouse:272", hl.dsp.window.resize(),
        { description = "Resize window", mouse = true })
end)

section("binds.resize", function()
    hl.bind(mainMod .. " + SHIFT + LEFT",  hl.dsp.window.resize({ x = -50, y = 0,   relative = true }), { description = "Resize left" })
    hl.bind(mainMod .. " + SHIFT + RIGHT", hl.dsp.window.resize({ x = 50,  y = 0,   relative = true }), { description = "Resize right" })
    hl.bind(mainMod .. " + SHIFT + UP",    hl.dsp.window.resize({ x = 0,   y = -50, relative = true }), { description = "Resize up" })
    hl.bind(mainMod .. " + SHIFT + DOWN",  hl.dsp.window.resize({ x = 0,   y = 50,  relative = true }), { description = "Resize down" })
end)

section("binds.move", function()
    hl.bind(mainMod .. " + CTRL + LEFT",  hl.dsp.window.move({ direction = "l" }), { description = "Move window left" })
    hl.bind(mainMod .. " + CTRL + RIGHT", hl.dsp.window.move({ direction = "r" }), { description = "Move window right" })
    hl.bind(mainMod .. " + CTRL + UP",    hl.dsp.window.move({ direction = "u" }), { description = "Move window up" })
    hl.bind(mainMod .. " + CTRL + DOWN",  hl.dsp.window.move({ direction = "d" }), { description = "Move window down" })
end)

section("binds.swap", function()
    hl.bind(mainMod .. " + ALT + LEFT",  hl.dsp.window.swap({ direction = "l" }), { description = "Swap window left" })
    hl.bind(mainMod .. " + ALT + RIGHT", hl.dsp.window.swap({ direction = "r" }), { description = "Swap window right" })
    hl.bind(mainMod .. " + ALT + UP",    hl.dsp.window.swap({ direction = "u" }), { description = "Swap window up" })
    hl.bind(mainMod .. " + ALT + DOWN",  hl.dsp.window.swap({ direction = "d" }), { description = "Swap window down" })
end)

section("binds.workspace.nav", function()
    hl.bind(mainMod .. " + TAB",         hl.dsp.focus({ workspace = "m+1" }), { description = "Next workspace" })
    hl.bind(mainMod .. " + SHIFT + TAB", hl.dsp.focus({ workspace = "m-1" }), { description = "Previous workspace" })

    hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }), { description = "Next workspace" })
    hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }), { description = "Previous workspace" })

    hl.bind(mainMod .. " + PERIOD", hl.dsp.focus({ workspace = "e+1" }), { description = "Next workspace" })
    hl.bind(mainMod .. " + COMMA",  hl.dsp.focus({ workspace = "e-1" }), { description = "Previous workspace" })
end)





section("binds.workspace.numbers", function()
    local workspaceKeys = {
        { "code:10", 1 },
        { "code:11", 2 },
        { "code:12", 3 },
        { "code:13", 4 },
        { "code:14", 5 },
        { "code:15", 6 },
        { "code:16", 7 },
        { "code:17", 8 },
        { "code:18", 9 },
        { "code:19", 10 },
    }

    for _, item in ipairs(workspaceKeys) do
        local key, ws = item[1], item[2]

        hl.bind(mainMod .. " + " .. key,
            hl.dsp.focus({ workspace = ws }),
            { description = "Workspace " .. ws })

        hl.bind(mainMod .. " + SHIFT + " .. key,
            hl.dsp.window.move({ workspace = ws, follow = false }),
            { description = "Move silently to workspace " .. ws })

        hl.bind(mainMod .. " + CTRL + " .. key,
            hl.dsp.window.move({ workspace = ws }),
            { description = "Move to workspace " .. ws })
    end
end)

section("binds.media", function()
    -- Volume
    hl.bind("XF86AudioMute",
        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
        { description = "Mute volume" })

    hl.bind("XF86AudioLowerVolume",
        hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
        { description = "Volume down" })

    hl.bind("XF86AudioRaiseVolume",
        hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"),
        { description = "Volume up" })

    -- Microphone
    hl.bind("XF86Launch6",
        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
        { description = "Mute microphone" })

    -- Brightness
    hl.bind("XF86MonBrightnessDown",
        hl.dsp.exec_cmd("brightnessctl set 5%-"),
        { description = "Brightness down" })

    hl.bind("XF86MonBrightnessUp",
        hl.dsp.exec_cmd("brightnessctl set 5%+"),
        { description = "Brightness up" })
end)