local exec = require("modules.util").exec
local vars = require("modules.vars")

hl.on("hyprland.start", function()
    exec(vars.terminal)
    exec("waybar")
    exec("quickshell -c pill")
    exec("quickshell -c launcher")
    exec("hyprpaper")
    exec("code /etc/nixos")
    exec("quickshell -c waybar-island")
    exec("kitty -- btop")
end)