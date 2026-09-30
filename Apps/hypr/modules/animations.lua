local util = require("modules.util")
local section, safe = util.section, util.safe

section("curves", function()
    local curves = {
        wind      = { { 0.05, 0.9 }, { 0.1, 1.0 } },
        winIn     = { { 0.1, 1.0 },  { 0.1, 1.0 } },
        winOut    = { { 0.3, 0.0 },  { 0.0, 1.0 } },
        liner     = { { 1.0, 1.0 },  { 1.0, 1.0 } },
        overshot  = { { 0.05, 0.9 }, { 0.1, 1.0 } },
        smoothOut = { { 0.5, 0.0 },  { 0.99, 0.99 } },
        smoothIn  = { { 0.5, 0.0 },  { 0.68, 1.0 } },
    }
    for name, points in pairs(curves) do
        safe(hl.curve, name, { type = "bezier", points = points })
    end
end)

section("animations", function()
    local animations = {
        { leaf = "global",        enabled = true, speed = 10,  bezier = "wind" },
        { leaf = "windows",       enabled = true, speed = 6,   bezier = "wind",      style = "slide" },
        { leaf = "windowsIn",     enabled = true, speed = 5,   bezier = "winIn",     style = "slide" },
        { leaf = "windowsOut",    enabled = true, speed = 3,   bezier = "smoothOut", style = "slide" },
        { leaf = "windowsMove",   enabled = true, speed = 5,   bezier = "wind",      style = "slide" },
        { leaf = "border",        enabled = true, speed = 1,   bezier = "liner" },
        { leaf = "borderangle",   enabled = true, speed = 100, bezier = "liner",     style = "loop" },
        { leaf = "fade",          enabled = true, speed = 3,   bezier = "smoothOut" },
        { leaf = "workspaces",    enabled = true, speed = 5,   bezier = "overshot",  style = "slide" },
        { leaf = "workspacesIn",  enabled = true, speed = 5,   bezier = "winIn",     style = "slide" },
        { leaf = "workspacesOut", enabled = true, speed = 5,   bezier = "winOut",    style = "slide" },
    }
    for _, anim in ipairs(animations) do
        safe(hl.animation, anim)
    end
end)