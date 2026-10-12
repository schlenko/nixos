local util = require("modules.util")
local section, safe = util.section, util.safe

section("layer rules", function()
    local rules = {
        { match = { namespace = "rofi" },                       blur = true, ignore_alpha = 0, animation = "popin" },
        { match = { namespace = "notifications" },              blur = true, ignore_alpha = 0, animation = "slide" },
        { match = { namespace = "quickshell:overview" },        blur = true, ignore_alpha = 0.5 },
        { match = { namespace = "quickshell:expose" },          dim_around = true, blur = true, ignore_alpha = 0, xray = true },
        { match = { namespace = "wallpaper" },                  blur = true, ignore_alpha = 0 },
        { match = { namespace = "swaync-notification-window" }, blur = true, ignore_alpha = 0 },
        { match = { namespace = "com.aurora.keybinds_help" },   blur = true, ignore_alpha = 0 },
        { match = { namespace = "logout_dialog" },              blur = true, ignore_alpha = 0 },
        { match = { namespace = "waybar" },                     blur = true, ignore_alpha = 0 },

    }
    for _, rule in ipairs(rules) do
        safe(hl.layer_rule, rule)
    end
end)

section("window rules", function()
    local rules = {
        { match = { class = "^([Ff]irefox|org.mozilla.firefox|[Ff]irefox-esr|[Ff]irefox-bin)$" }, tag = "+browser" },
        { match = { class = "^(chromium)$" },                                                      tag = "+browser" },
        { match = { class = "^(kitty|kitty-dropterm)$" },                                          tag = "+terminal" },
        { match = { class = "^([Tt]hunar|org.gnome.Nautilus|[Pp]cmanfm-qt)$" },                    tag = "+file-manager" },

        { match = { class = "^(mpv|com.github.rafostar.Clapper)$" },        float = true },
        { match = { class = "^(qalculate-gtk|[Qq]alculate-gtk)$" },         float = true },
        { match = { class = "^(zoom|Zoom|onedriver|onedriver-launcher)$" }, float = true },

        -- All windows: focused = 1.0, unfocused = 0.88
        { match = { class = ".*" }, opacity = "1.0 0.88" },

        -- MPV/VLC: disable blur, but inherit the global opacity rule
        { match = { class = "^(mpv|vlc)$" }, no_blur = true },

        { match = { fullscreen = true }, idle_inhibit = "fullscreen" },
    }

    for _, rule in ipairs(rules) do
        safe(hl.window_rule, rule)
    end
end)
