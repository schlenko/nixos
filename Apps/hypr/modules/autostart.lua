local exec = require("modules.util").exec
local vars = require("modules.vars")

hl.on("hyprland.start", function()
    exec(vars.terminal)
    exec("hyprlock")
    exec("waybar")
    exec("awww-daemon")
    exec("mako")
    exec("kitty -- lazygit --path /etc/nixos")
    exec("kitty -- tui-globe")
    exec([[kitty -- sh -c 'reset; fastfetch -c ~/.config/fastfetch/nixos-01.jsonc; read -n 1 -s -r']])
end)