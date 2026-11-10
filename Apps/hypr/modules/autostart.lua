local util = require("modules.util")
local vars = require("modules.vars")

local GAP = 0.3 -- seconds between each app, change this
local T = vars.terminal
local HOME = os.getenv("HOME")
local FLAG = (os.getenv("XDG_RUNTIME_DIR") or "/tmp") .. "/hypr-layout-done"
local WALLPAPER_DIR = HOME .. "/Pictures/Wallpapers/Best"
-- started one by one, in this order, after you unlock
local apps = {
    T,
    T .. " -- cmatrix -b -C magenta",
    T .. " -- bash " .. HOME .. "/.config/hypr/scripts/fetch-autostart.sh",
    "waybar",
}


local parts = {
    "for i in $(seq 30); do pgrep -x hyprlock >/dev/null && break; sleep 0.1; done",
    "while pgrep -x hyprlock >/dev/null; do sleep 0.2; done",
    "rm -f " .. FLAG,

    -- Set wallpaper first
    "awww img \"$(find " .. WALLPAPER_DIR .. " -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \\) | shuf -n 1)\" --transition-type wipe --transition-angle 135 --transition-duration 0.8 --transition-fps 60",

    -- Wait for the transition to finish
    "sleep 0.8",
}

for _, cmd in ipairs(apps) do
    parts[#parts + 1] = cmd .. " & sleep " .. GAP
end

parts[#parts + 1] = "touch " .. FLAG

hl.on("hyprland.start", function()
    -- daemon starts right away, ignoring the cached wallpaper, and is set to black
    util.exec("awww-daemon --no-cache")
    util.exec("awww clear")
    util.exec("mako")
    util.exec("hyprlock")
    util.exec("hyprsunset -t 4500")
    util.exec("hyprctl setcursor '' 0")
    util.exec("sh -c \"" .. table.concat(parts, "; "):gsub('"', '\\"'):gsub("%$", "\\$") .. "\"")
end)