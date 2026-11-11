local util = require("modules.util")
local section, safe = util.section, util.safe

section("curves", function()
    local curves = {
        easeOutQuint = {
            { 0.23, 1.0 },
            { 0.32, 1.0 },
        },

        easeInOutCubic = {
            { 0.65, 0.05 },
            { 0.36, 1.0 },
        },

        linear = {
            { 0.0, 0.0 },
            { 1.0, 1.0 },
        },

        almostLinear = {
            { 0.5, 0.5 },
            { 0.75, 1.0 },
        },

        quick = {
            { 0.25, 0.1 },
            { 0.25, 1.0 },
        },
    }

    for name, points in pairs(curves) do
        safe(hl.curve, name, {
            type = "bezier",
            points = points,
        })
    end

    safe(hl.curve, "easy", {
        type = "spring",
        mass = 1,
        stiffness = 238.1191,
        dampening = 24.21279333,
    })

    safe(hl.curve, "snappy", {
    type = "spring",
    mass = 1,
    stiffness = 1600,
    dampening = 62,
    })

    safe(hl.curve, "snapnobounce", {
    type = "spring",
    mass = 1,
    stiffness = 1600,
    dampening = 80,   -- 2*sqrt(1600): no overshoot
    })

    safe(hl.curve, "silk", {
    type = "spring",
    mass = 1,
    stiffness = 220,
    dampening = 26,   -- lower = a tiny settle at the end, higher = no bounce
    })
    
end)


section("animations", function()
    local animations = {
        { leaf = "global",        enabled = true, speed = 10,   bezier = "default" },
        { leaf = "border",        enabled = true, speed = 6,    bezier = "easeOutQuint" },

        { leaf = "windows",       enabled = true, speed = 3,    spring = "easy" },
        { leaf = "windowsIn",     enabled = true, speed = 5,    spring = "easy", style = "popin 87%" },
        { leaf = "windowsOut",    enabled = true, speed = 3,    bezier = "linear", style = "popin 87%" },
        { leaf = "windowsMove",   enabled = true, speed = 1,    spring = "snappy" },

        { leaf = "fadeIn",        enabled = true, speed = 3.2,  bezier = "almostLinear" },
        { leaf = "fadeOut",       enabled = true, speed = 3,    bezier = "almostLinear" },
        { leaf = "fade",          enabled = true, speed = 4.5,  bezier = "quick" },

        { leaf = "layers",        enabled = true, speed = 3,    bezier = "easeOutQuint" },
        { leaf = "layersIn",      enabled = true, speed = 1,   spring = "snappy", style = "slidefade 8%" },
        { leaf = "layersOut",     enabled = true, speed = 1,   spring = "snappy", style = "slidefade 8%" },
        { leaf = "fadeLayersIn",  enabled = true, speed = 2,   bezier = "quick" },
        { leaf = "fadeLayersOut", enabled = true, speed = 1.5, bezier = "quick" },
        { leaf = "workspaces",    enabled = true, speed = 1.2, bezier = "quick", style = "slidefade 20%" },
        { leaf = "workspacesIn",  enabled = true, speed = 1.2, bezier = "quick", style = "slidefade 20%" },
        { leaf = "workspacesOut", enabled = true, speed = 1,   bezier = "quick", style = "slidefade 20%" },
        { leaf = "zoomFactor",    enabled = true, speed = 8,    bezier = "quick" },
    }

    for _, anim in ipairs(animations) do
        safe(hl.animation, anim)
    end
end)