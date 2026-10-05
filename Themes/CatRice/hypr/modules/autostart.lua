local exec = require("modules.util").exec
local vars = require("modules.vars")

hl.on("hyprland.start", function()
    exec(vars.terminal)
    exec("hyprlock")
    exec("waybar")
    exec("hyprpaper")
    exec("code /etc/nixos")
    exec("kitty -- gotop")
end)