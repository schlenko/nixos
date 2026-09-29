-- ~/.config/hypr/hyprland.lua
-- Every section is wrapped in `section()` so one bad option can no longer
-- kill the whole file. Errors are printed to the Hyprland log
-- (check with: hyprctl configerrors  and  hyprctl rollinglog)

local mainMod = "SUPER"

-- Programs
local terminal = "kitty"
local launcher = "rofi -show run"

local function section(name, fn)
    local ok, err = pcall(fn)
    if not ok then
        print("[hyprland.lua] section '" .. name .. "' failed: " .. tostring(err))
    end
end

local function safe(fn, ...)
    local ok, err = pcall(fn, ...)
    if not ok then
        print("[hyprland.lua] " .. tostring(err))
    end
end

local exec = hl.exec_cmd or function(cmd)
    hl.dispatch(hl.dsp.exec_cmd(cmd))
end

----------------------------------------------------------------------
-- Environment
----------------------------------------------------------------------
section("env", function()
    hl.env("DOTS_VERSION", "2.3.26.4")

    hl.env("GDK_BACKEND", "wayland,x11,*")
    hl.env("QT_QPA_PLATFORM", "wayland;xcb")
    hl.env("CLUTTER_BACKEND", "wayland")

    hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
    hl.env("XDG_SESSION_DESKTOP", "Hyprland")
    hl.env("XDG_SESSION_TYPE", "wayland")

    hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
    hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
    hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
    hl.env("QT_STYLE_OVERRIDE", "Fusion")
    hl.env("QT_QUICK_CONTROLS_STYLE", "Basic")

    hl.env("GDK_SCALE", "1")
    hl.env("QT_SCALE_FACTOR", "1")

    hl.env("HYPRCURSOR_THEME", "Adwaita")
    hl.env("HYPRCURSOR_SIZE", "24")
    hl.env("XCURSOR_THEME", "Adwaita")
    hl.env("XCURSOR_SIZE", "24")

    hl.env("MOZ_ENABLE_WAYLAND", "1")
    hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

    -- NVIDIA / VM compatibility
    -- (comment the two nvidia lines out if you do NOT have an NVIDIA GPU)
    hl.env("LIBVA_DRIVER_NAME", "nvidia")
    hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
    hl.env("NVD_BACKEND", "direct")
    hl.env("GSK_RENDERER", "ngl")
    hl.env("WLR_RENDERER_ALLOW_SOFTWARE", "1")
end)

----------------------------------------------------------------------
-- Config (split per category so one bad key only affects its category)
----------------------------------------------------------------------
section("config.general", function()
    hl.config({
        general = {
            border_size = 2,
            resize_on_border = true,
            layout = "dwindle",
            col = {
                active_border = "rgb(C3A5E6)",
                inactive_border = "rgb(3F3F42)",
            },
        },
    })
end)

section("config.decoration", function()
    hl.config({
        decoration = {
            rounding = 3,
            active_opacity = 1.0,
            inactive_opacity = 1.0,
            blur = {
                enabled = true,
                size = 5,
                passes = 4,
                new_optimizations = true,
                xray = false,
            },
        },
    })
end)

section("config.input", function()
    hl.config({
        input = {
            kb_layout = "de",
            kb_model = "pc105",
            kb_options = "",

            repeat_rate = 50,
            repeat_delay = 300,

            sensitivity = 0,
            numlock_by_default = true,
            left_handed = false,
            follow_mouse = 1,
            float_switch_override_focus = false,

            touchpad = {
                disable_while_typing = false,
                clickfinger_behavior = false,
                middle_button_emulation = false,
                tap_to_click = true,
                drag_lock = false,
            },

            touchdevice = {
                enabled = true,
            },

            tablet = {
                transform = 0,
                left_handed = false,
            },
        },
    })
end)

section("config.dwindle", function()
    hl.config({
        dwindle = {
            preserve_split = true,
            smart_resizing = true,
            use_active_for_splits = true,
            smart_split = false,
            default_split_ratio = 1.0,
            split_bias = 0,
            precise_mouse_move = false,
            special_scale_factor = 0.8,
        },
    })
end)

section("config.master", function()
    hl.config({
        master = {
            new_status = "slave",
            new_on_top = false,
            new_on_active = "none",
            orientation = "left",
            mfact = 0.55,
            slave_count_for_center_master = 2,
            center_master_fallback = "left",
            smart_resizing = true,
            drop_at_cursor = true,
            always_keep_position = false,
        },
    })
end)

section("config.misc", function()
    hl.config({
        misc = {
            disable_hyprland_logo = true,
            disable_splash_rendering = true,
            force_default_wallpaper = false,
            vrr = 0,
            mouse_move_enables_dpms = true,
            enable_swallow = false,
            swallow_regex = "^(kitty)$",
            focus_on_activate = false,
            initial_workspace_tracking = 0,
            middle_click_paste = false,
            enable_anr_dialog = true,
            anr_missed_pings = 15,
            allow_session_lock_restore = true,
            on_focus_under_fullscreen = 1,
        },
    })
end)

section("config.binds", function()
    hl.config({
        binds = {
            workspace_back_and_forth = true,
            allow_workspace_cycles = true,
            pass_mouse_when_bound = false,
        },
    })
end)

section("config.xwayland", function()
    hl.config({
        xwayland = {
            enabled = true,
            force_zero_scaling = true,
        },
    })
end)

section("config.render", function()
    hl.config({
        render = {
            direct_scanout = 0,
        },
    })
end)

section("config.cursor", function()
    hl.config({
        cursor = {
            sync_gsettings_theme = true,
            no_hardware_cursors = false,
            enable_hyprcursor = true,
            warp_on_change_workspace = 2,
            no_warps = true,
            no_break_fs_vrr = false,
            min_refresh_rate = 24,
            hotspot_padding = 1,
            inactive_timeout = 0,
            zoom_factor = 1.0,
            zoom_rigid = false,
            zoom_detached_camera = true,
            hide_on_key_press = true,
            hide_on_touch = false,
            hide_on_tablet = false,
            use_cpu_buffer = false,
        },
    })
end)

----------------------------------------------------------------------
-- Animation curves
----------------------------------------------------------------------
section("curves", function()
    local curves = {
        wind      = { { 0.05, 0.9 }, { 0.1, 1.0 } },
        winIn     = { { 0.1, 1.0 },  { 0.1, 1.0 } },
        winOut    = { { 0.3, 0.0 },  { 0.0, 1.0 } },
        liner     = { { 1.0, 1.0 },  { 1.0, 1.0 } },
        overshot  = { { 0.05, 0.9 }, { 0.1, 1.0 } },
        smoothOut = { { 0.5, 0.0 },  { 0.99, 0.99 } },
        smoothIn  = { { 0.5, 0.0 },  { 0.68, 1.0 } },
    }
    for name, points in pairs(curves) do
        safe(hl.curve, name, { type = "bezier", points = points })
    end
end)

----------------------------------------------------------------------
-- Animations
----------------------------------------------------------------------
section("animations", function()
    local animations = {
        { leaf = "global",        enabled = true, speed = 10,  bezier = "wind" },
        { leaf = "windows",       enabled = true, speed = 6,   bezier = "wind",      style = "slide" },
        { leaf = "windowsIn",     enabled = true, speed = 5,   bezier = "winIn",     style = "slide" },
        { leaf = "windowsOut",    enabled = true, speed = 3,   bezier = "smoothOut", style = "slide" },
        { leaf = "windowsMove",   enabled = true, speed = 5,   bezier = "wind",      style = "slide" },
        { leaf = "border",        enabled = true, speed = 1,   bezier = "liner" },
        { leaf = "borderangle",   enabled = true, speed = 100, bezier = "liner",     style = "loop" },
        { leaf = "fade",          enabled = true, speed = 3,   bezier = "smoothOut" },
        { leaf = "workspaces",    enabled = true, speed = 5,   bezier = "overshot",  style = "slide" },
        { leaf = "workspacesIn",  enabled = true, speed = 5,   bezier = "winIn",     style = "slide" },
        { leaf = "workspacesOut", enabled = true, speed = 5,   bezier = "winOut",    style = "slide" },
    }
    for _, anim in ipairs(animations) do
        safe(hl.animation, anim)
    end
end)

----------------------------------------------------------------------
-- Monitor / workspace rules
----------------------------------------------------------------------
section("monitor", function()
    hl.monitor({
        output = "eDP-1",
        mode = "preferred",
        position = "0x0",
        scale = 1,
    })
end)

section("workspace rules", function()
    hl.workspace_rule({
        workspace = "1",
        monitor = "eDP-1",
        layout = "dwindle",
    })
end)

----------------------------------------------------------------------
-- Keybinds: applications
----------------------------------------------------------------------
section("binds.apps", function()
    hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal),
        { description = "Open terminal" })

    hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("pkill rofi || " .. launcher),
        { description = "App launcher" })

    hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("xdg-open https://duckduckgo.com"),
        { description = "Open default browser" })

    hl.bind(mainMod .. " + CTRL + TAB", hl.dsp.exec_cmd("qs -c overview"),
        { description = "Overview toggle" })
end)

----------------------------------------------------------------------
-- Keybinds: window management (essentials)
----------------------------------------------------------------------
section("binds.window", function()
    hl.bind(mainMod .. " + Q", hl.dsp.window.close(),
        { description = "Close window" })

    hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }),
        { description = "Toggle floating" })

    hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen(),
        { description = "Toggle fullscreen" })

    hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exit(),
        { description = "Exit Hyprland" })

    -- Focus with SUPER + arrows
    hl.bind(mainMod .. " + LEFT",  hl.dsp.focus({ direction = "left" }),  { description = "Focus left" })
    hl.bind(mainMod .. " + RIGHT", hl.dsp.focus({ direction = "right" }), { description = "Focus right" })
    hl.bind(mainMod .. " + UP",    hl.dsp.focus({ direction = "up" }),    { description = "Focus up" })
    hl.bind(mainMod .. " + DOWN",  hl.dsp.focus({ direction = "down" }),  { description = "Focus down" })
end)

section("binds.mouse", function()
    hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),
        { description = "Move window", mouse = true })

    hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(),
        { description = "Resize window", mouse = true })
end)

section("binds.resize", function()
    hl.bind(mainMod .. " + SHIFT + LEFT",  hl.dsp.window.resize({ x = -50, y = 0,   relative = true }), { description = "Resize left" })
    hl.bind(mainMod .. " + SHIFT + RIGHT", hl.dsp.window.resize({ x = 50,  y = 0,   relative = true }), { description = "Resize right" })
    hl.bind(mainMod .. " + SHIFT + UP",    hl.dsp.window.resize({ x = 0,   y = -50, relative = true }), { description = "Resize up" })
    hl.bind(mainMod .. " + SHIFT + DOWN",  hl.dsp.window.resize({ x = 0,   y = 50,  relative = true }), { description = "Resize down" })
end)

section("binds.move", function()
    hl.bind(mainMod .. " + CTRL + LEFT",  hl.dsp.window.move({ direction = "l" }), { description = "Move window left" })
    hl.bind(mainMod .. " + CTRL + RIGHT", hl.dsp.window.move({ direction = "r" }), { description = "Move window right" })
    hl.bind(mainMod .. " + CTRL + UP",    hl.dsp.window.move({ direction = "u" }), { description = "Move window up" })
    hl.bind(mainMod .. " + CTRL + DOWN",  hl.dsp.window.move({ direction = "d" }), { description = "Move window down" })
end)

section("binds.swap", function()
    hl.bind(mainMod .. " + ALT + LEFT",  hl.dsp.window.swap({ direction = "l" }), { description = "Swap window left" })
    hl.bind(mainMod .. " + ALT + RIGHT", hl.dsp.window.swap({ direction = "r" }), { description = "Swap window right" })
    hl.bind(mainMod .. " + ALT + UP",    hl.dsp.window.swap({ direction = "u" }), { description = "Swap window up" })
    hl.bind(mainMod .. " + ALT + DOWN",  hl.dsp.window.swap({ direction = "d" }), { description = "Swap window down" })
end)

----------------------------------------------------------------------
-- Keybinds: workspaces
----------------------------------------------------------------------
section("binds.workspace.nav", function()
    hl.bind(mainMod .. " + TAB",         hl.dsp.focus({ workspace = "m+1" }), { description = "Next workspace" })
    hl.bind(mainMod .. " + SHIFT + TAB", hl.dsp.focus({ workspace = "m-1" }), { description = "Previous workspace" })

    hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }), { description = "Next workspace" })
    hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }), { description = "Previous workspace" })

    hl.bind(mainMod .. " + PERIOD", hl.dsp.focus({ workspace = "e+1" }), { description = "Next workspace" })
    hl.bind(mainMod .. " + COMMA",  hl.dsp.focus({ workspace = "e-1" }), { description = "Previous workspace" })
end)

section("binds.workspace.numbers", function()
    -- physical keys 1..0 on the top row (keycodes 10..19, layout independent)
    local workspaceKeys = {
        { "code:10", 1 },
        { "code:11", 2 },
        { "code:12", 3 },
        { "code:13", 4 },
        { "code:14", 5 },
        { "code:15", 6 },
        { "code:16", 7 },
        { "code:17", 8 },
        { "code:18", 9 },
        { "code:19", 10 },
    }

    for _, item in ipairs(workspaceKeys) do
        local key, ws = item[1], item[2]

        hl.bind(mainMod .. " + " .. key,
            hl.dsp.focus({ workspace = ws }),
            { description = "Workspace " .. ws })

        hl.bind(mainMod .. " + SHIFT + " .. key,
            hl.dsp.window.move({ workspace = ws, follow = false }),
            { description = "Move silently to workspace " .. ws })

        hl.bind(mainMod .. " + CTRL + " .. key,
            hl.dsp.window.move({ workspace = ws }),
            { description = "Move to workspace " .. ws })
    end
end)

section("binds.workspace.move_adjacent", function()
    hl.bind(mainMod .. " + SHIFT + BRACKETLEFT",
        hl.dsp.window.move({ workspace = "m-1", follow = false }),
        { description = "Move silently to previous workspace" })

    hl.bind(mainMod .. " + SHIFT + BRACKETRIGHT",
        hl.dsp.window.move({ workspace = "m+1", follow = false }),
        { description = "Move silently to next workspace" })

    hl.bind(mainMod .. " + CTRL + BRACKETLEFT",
        hl.dsp.window.move({ workspace = "m-1" }),
        { description = "Move to previous workspace" })

    hl.bind(mainMod .. " + CTRL + BRACKETRIGHT",
        hl.dsp.window.move({ workspace = "m+1" }),
        { description = "Move to next workspace" })
end)

----------------------------------------------------------------------
-- Gestures
----------------------------------------------------------------------
section("gestures", function()
    safe(hl.gesture, { fingers = 3, direction = "horizontal", action = "workspace" })

    safe(hl.gesture, {
        fingers = 3, direction = "up", action = "cursorZoom",
        zoom_level = "1.5", mode = "mult",
    })

    safe(hl.gesture, {
        fingers = 3, direction = "down", action = "cursorZoom",
        zoom_level = "1.5", mode = "mult",
    })

    safe(hl.gesture, {
        fingers = 4, direction = "up",
        action = function()
            exec("sh ~/.config/hypr/scripts/OverviewToggle.sh")
        end,
    })

    safe(hl.gesture, { fingers = 4, direction = "down", action = "float" })
end)

----------------------------------------------------------------------
-- Layer rules
----------------------------------------------------------------------
section("layer rules", function()
    local rules = {
        { match = { namespace = "rofi" },                     blur = true, ignore_alpha = 0, animation = "slide" },
        { match = { namespace = "notifications" },            blur = true, ignore_alpha = 0, animation = "slide" },
        { match = { namespace = "quickshell:overview" },      blur = true, ignore_alpha = 0.5 },
        { match = { namespace = "quickshell:expose" },        dim_around = true, blur = true, ignore_alpha = 0, xray = true },
        { match = { namespace = "wallpaper" },                blur = true, ignore_alpha = 0 },
        { match = { namespace = "swaync-notification-window" }, blur = true, ignore_alpha = 0 },
        { match = { namespace = "com.aurora.keybinds_help" }, blur = true, ignore_alpha = 0 },
        { match = { namespace = "logout_dialog" },            blur = true, ignore_alpha = 0 },
    }
    for _, rule in ipairs(rules) do
        safe(hl.layer_rule, rule)
    end
end)

----------------------------------------------------------------------
-- Window rules
----------------------------------------------------------------------
section("window rules", function()
    local rules = {
        -- Tags
        { match = { class = "^([Ff]irefox|org.mozilla.firefox|[Ff]irefox-esr|[Ff]irefox-bin)$" }, tag = "+browser" },
        { match = { class = "^(chromium)$" },                                                      tag = "+browser" },
        { match = { class = "^(kitty|kitty-dropterm)$" },                                          tag = "+terminal" },
        { match = { class = "^([Tt]hunar|org.gnome.Nautilus|[Pp]cmanfm-qt)$" },                    tag = "+file-manager" },

        -- Floating
        { match = { class = "^(mpv|com.github.rafostar.Clapper)$" },             float = true },
        { match = { class = "^(qalculate-gtk|[Qq]alculate-gtk)$" },              float = true },
        { match = { class = "^(zoom|Zoom|onedriver|onedriver-launcher)$" },      float = true },

        -- Opacity
        { match = { tag = "browser" },       opacity = "0.99 0.8" },
        { match = { tag = "terminal" },      opacity = "0.9 0.7" },
        { match = { tag = "file-manager" },  opacity = "0.9 0.8" },

        -- Multimedia
        { match = { class = "^(mpv|vlc)$" }, no_blur = true, opacity = "1.0" },

        -- Fullscreen prevents idle
        { match = { fullscreen = true },     idle_inhibit = "fullscreen" },
    }
    for _, rule in ipairs(rules) do
        safe(hl.window_rule, rule)
    end
end)

----------------------------------------------------------------------
-- Startup
----------------------------------------------------------------------
hl.on("hyprland.start", function()
    exec("waybar")
    exec("quickshell -c waybar-island")
    exec("quickshell -c pill")
    exec("quickshell -c launcher")
    exec("hyprpaper")
    exec(terminal)
    exec("code /etc/nixos")
end)