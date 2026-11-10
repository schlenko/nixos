local util = require("modules.util")
local vars = require("modules.vars")

local GAP = 0.2 -- seconds between each app, change this
local T = vars.terminal
local HOME = os.getenv("HOME")
local FLAG = (os.getenv("XDG_RUNTIME_DIR") or "/tmp") .. "/hypr-layout-done"

-- started one by one, in this order, after you unlock
local apps = {
    T .. " -- lazygit --path /etc/nixos",
    T .. " -- bash " .. HOME .. "/.config/hypr/scripts/fetch-autostart.sh",
    T .. " -- cmatrix -b -C blue",
    T,
    "code",
    "waybar",
}

-- VS Code opens silently on workspace 2
util.safe(hl.window_rule, {
    match = { class = "^(Code|code)$" },
    workspace = "2 silent",
})

-- build one shell line: wait for unlock, then start each app with a gap
local parts = {
    "for i in $(seq 30); do pgrep -x hyprlock >/dev/null && break; sleep 0.1; done",
    "while pgrep -x hyprlock >/dev/null; do sleep 0.2; done",
    "rm -f " .. FLAG,
}
for _, cmd in ipairs(apps) do
    parts[#parts + 1] = cmd .. " & sleep " .. GAP
end
parts[#parts + 1] = "touch " .. FLAG

hl.on("hyprland.start", function()    util.exec("awww-daemon")
    util.exec("mako")
    util.exec("hyprlock")
    util.exec("hyprsunset -t 4500")
    util.exec("sh -c '" .. table.concat(parts, "; ") .. "'")
end)
