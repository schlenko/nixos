local exec = require("modules.util").exec
local vars = require("modules.vars")

hl.on("hyprland.start", function()
    exec("waybar")
    exec("quickshell -c waybar-island")
    exec("quickshell -c pill")
    exec("quickshell -c launcher")
    exec("hyprpaper")
    exec(vars.terminal)
    exec("code /etc/nixos")
end)