local exec = require("modules.util").exec
local vars = require("modules.vars")

hl.on("hyprland.start", function()
    exec(vars.terminal)
    exec("hyprlock")
    exec("waybar")
    exec("awww-daemon")
    exec("mako")
    exec("code /etc/nixos")
    exec("kitty -- lazygit --path /etc/nixos")
    exec("sleep 5 && encom-globe")
end)