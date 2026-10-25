local util = require("modules.util")
local vars = require("modules.vars")

local HOME = os.getenv("HOME")
local RUNTIME = os.getenv("XDG_RUNTIME_DIR") or "/tmp"
local FLAG = RUNTIME .. "/hypr-layout-done"

-- How far the horizontal split lines are pushed apart (pixels).
-- Left split moves UP by this much, right split moves DOWN by this much.
local STAGGER = 150

local T = vars.terminal

local apps = {
    globe = { class = "as-globe", cmd = T .. " --class as-globe -- tui-globe" },
    fetch = { class = "as-fetch", cmd = T .. " --class as-fetch -- bash " .. HOME .. "/.config/hypr/scripts/fetch-autostart.sh" },
    git   = { class = "as-git",   cmd = T .. " --class as-git -- lazygit --path /etc/nixos" },
    term  = { class = "as-term",  cmd = T .. " --class as-term" },
    cava  = { class = "as-cava",  cmd = T .. " --class as-cava -- cava" },
    code  = { class = "Code",     cmd = "code", nowait = true },
}

-- Window rules: everything on workspace 1, VS Code silently on workspace 2
for _, name in ipairs({ "globe", "fetch", "git", "term", "cava" }) do
    util.safe(hl.window_rule, {
        match = { class = "^" .. apps[name].class .. "$" },
        workspace = "1",
    })
end
util.safe(hl.window_rule, {
    match = { class = "^(Code|code)$" },
    workspace = "2 silent",
})

-- Script builder
local steps = { "#!/usr/bin/env bash", "rm -f " .. FLAG }

local function add(s) steps[#steps + 1] = s end

local function dispatch(expr)
    add(string.format("hyprctl dispatch '%s' >/dev/null", expr))
    add("sleep 0.15")
end

local function launch(app)
    add(app.cmd .. " &")
    if not app.nowait then
        add(string.format(
            [[for i in $(seq 80); do hyprctl clients -j | jq -e '.[] | select(.class=="%s")' >/dev/null && break; sleep 0.1; done]],
            app.class))
    end
    add("sleep 0.4")
end

local function preselect(dir) dispatch('hl.dsp.layout("preselect ' .. dir .. '")') end
local function focus(dir)     dispatch('hl.dsp.focus({ direction = "' .. dir .. '" })') end
local function resize_y(px)
    dispatch(string.format("hl.dsp.window.resize({ x = 0, y = %d, relative = true })", px))
end

-- Layout sequence
launch(apps.globe)

preselect("r")
launch(apps.fetch)          -- globe | fetch

focus("left")               -- globe
preselect("d")
launch(apps.git)            -- globe over git

preselect("r")
launch(apps.term)           -- git | term

focus("right")              -- fetch
preselect("d")
launch(apps.cava)           -- fetch over cava

focus("up")                 -- fetch
resize_y(STAGGER)           -- right: fetch taller, cava shorter
focus("left")               -- globe
resize_y(-STAGGER)          -- left: globe shorter, git/term taller

launch(apps.code)           -- workspace 2

add("touch " .. FLAG)       -- tells fastfetch the layout is final

hl.on("hyprland.start", function()
    util.exec("waybar")
    util.exec("awww-daemon")
    util.exec("mako")
    util.exec("hyprlock")

    local path = RUNTIME .. "/hypr-autostart.sh"
    local f = io.open(path, "w")
    if f then
        f:write(table.concat(steps, "\n") .. "\n")
        f:close()
        util.exec("bash " .. path)
    else
        print("[autostart] could not write " .. path)
    end
end)