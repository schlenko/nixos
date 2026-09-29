local mainMod = "SUPER"

-- Programs
local terminal = "kitty"
local launcher = "rofi -show run"

-- Environment
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
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("NVD_BACKEND", "direct")
hl.env("GSK_RENDERER", "ngl")
hl.env("WLR_RENDERER_ALLOW_SOFTWARE", "1")

-- General
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
            left_handed = 0,
        },
    },

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

    binds = {
        workspace_back_and_forth = true,
        allow_workspace_cycles = true,
        pass_mouse_when_bound = false,
    },

    xwayland = {
        enabled = true,
        force_zero_scaling = true,
    },

    render = {
        direct_scanout = 0,
    },

    cursor = {
        sync_gsettings_theme = true,
        no_hardware_cursors = 0,
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

-- Animation curves
hl.curve("wind", {
    type = "bezier",
    points = {
        { 0.05, 0.9 },
        { 0.1, 1.0 },
    },
})

hl.curve("winIn", {
    type = "bezier",
    points = {
        { 0.1, 1.0 },
        { 0.1, 1.0 },
    },
})

hl.curve("winOut", {
    type = "bezier",
    points = {
        { 0.3, 0.0 },
        { 0.0, 1.0 },
    },
})

hl.curve("liner", {
    type = "bezier",
    points = {
        { 1.0, 1.0 },
        { 1.0, 1.0 },
    },
})

hl.curve("overshot", {
    type = "bezier",
    points = {
        { 0.05, 0.9 },
        { 0.1, 1.0 },
    },
})

hl.curve("smoothOut", {
    type = "bezier",
    points = {
        { 0.5, 0.0 },
        { 0.99, 0.99 },
    },
})

hl.curve("smoothIn", {
    type = "bezier",
    points = {
        { 0.5, 0.0 },
        { 0.68, 1.0 },
    },
})

-- Animations
hl.animation({
    leaf = "global",
    enabled = true,
    speed = 10,
    bezier = "wind",
})

hl.animation({
    leaf = "windows",
    enabled = true,
    speed = 6,
    bezier = "wind",
    style = "slide",
})

hl.animation({
    leaf = "windowsIn",
    enabled = true,
    speed = 5,
    bezier = "winIn",
    style = "slide",
})

hl.animation({
    leaf = "windowsOut",
    enabled = true,
    speed = 3,
    bezier = "smoothOut",
    style = "slide",
})

hl.animation({
    leaf = "windowsMove",
    enabled = true,
    speed = 5,
    bezier = "wind",
    style = "slide",
})

hl.animation({
    leaf = "border",
    enabled = true,
    speed = 1,
    bezier = "liner",
})

hl.animation({
    leaf = "borderangle",
    enabled = true,
    speed = 180,
    bezier = "liner",
    style = "loop",
})

hl.animation({
    leaf = "fade",
    enabled = true,
    speed = 3,
    bezier = "smoothOut",
})

hl.animation({
    leaf = "workspaces",
    enabled = true,
    speed = 5,
    bezier = "overshot",
    style = "slide",
})

hl.animation({
    leaf = "workspacesIn",
    enabled = true,
    speed = 5,
    bezier = "winIn",
    style = "slide",
})

hl.animation({
    leaf = "workspacesOut",
    enabled = true,
    speed = 5,
    bezier = "winOut",
    style = "slide",
})

-- Monitor
hl.monitor({
    output = "eDP-1",
    mode = "preferred",
    position = "0x0",
    scale = 1,
})

-- Workspace
hl.workspace_rule({
    workspace = "1",
    monitor = "eDP-1",
    layout = "dwindle",
})

-- Workspace navigation
hl.bind(
    mainMod .. " + TAB",
    hl.focus.workspace("m+1"),
    { description = "Next workspace" }
)

hl.bind(
    mainMod .. " + SHIFT + TAB",
    hl.focus.workspace("m-1"),
    { description = "Previous workspace" }
)

hl.bind(
    mainMod .. " + CTRL + TAB",
    hl.dsp.exec_cmd("qs -c overview"),
    { description = "Hyprview toggle" }
)

-- Number workspaces
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
    local key = item[1]
    local workspace = item[2]

    hl.bind(
        mainMod .. " + " .. key,
        hl.focus.workspace(tostring(workspace)),
        { description = "Workspace " .. workspace }
    )

    hl.bind(
        mainMod .. " + SHIFT + " .. key,
        hl.dsp.move_to_workspace({
            workspace = tostring(workspace),
            silent = true,
        }),
        { description = "Move silently to workspace " .. workspace }
    )

    hl.bind(
        mainMod .. " + CTRL + " .. key,
        hl.dsp.move_to_workspace({
            workspace = tostring(workspace),
        }),
        { description = "Move to workspace " .. workspace }
    )
end

-- Workspace cycling
hl.bind(
    mainMod .. " + mouse_down",
    hl.focus.workspace("e+1"),
    { description = "Next workspace" }
)

hl.bind(
    mainMod .. " + mouse_up",
    hl.focus.workspace("e-1"),
    { description = "Previous workspace" }
)

hl.bind(
    mainMod .. " + PERIOD",
    hl.focus.workspace("e+1"),
    { description = "Next workspace" }
)

hl.bind(
    mainMod .. " + COMMA",
    hl.focus.workspace("e-1"),
    { description = "Previous workspace" }
)

-- Move window to adjacent workspace
hl.bind(
    mainMod .. " + SHIFT + BRACKETLEFT",
    hl.dsp.move_to_workspace({ workspace = "m-1", silent = true }),
    { description = "Move silently to previous workspace" }
)

hl.bind(
    mainMod .. " + SHIFT + BRACKETRIGHT",
    hl.dsp.move_to_workspace({ workspace = "m+1", silent = true }),
    { description = "Move silently to next workspace" }
)

hl.bind(
    mainMod .. " + CTRL + BRACKETLEFT",
    hl.dsp.move_to_workspace({ workspace = "m-1" }),
    { description = "Move to previous workspace" }
)

hl.bind(
    mainMod .. " + CTRL + BRACKETRIGHT",
    hl.dsp.move_to_workspace({ workspace = "m+1" }),
    { description = "Move to next workspace" }
)

-- Mouse window movement
hl.bind(
    mainMod .. " + mouse:272",
    hl.dsp.window.move(),
    { description = "Move window", mouse = true }
)

hl.bind(
    mainMod .. " + mouse:273",
    hl.dsp.window.resize(),
    { description = "Resize window", mouse = true }
)

-- Resize windows
hl.bind(
    mainMod .. " + SHIFT + LEFT",
    hl.dsp.window.resize({ x = -50, y = 0 }),
    { description = "Resize left" }
)

hl.bind(
    mainMod .. " + SHIFT + RIGHT",
    hl.dsp.window.resize({ x = 50, y = 0 }),
    { description = "Resize right" }
)

hl.bind(
    mainMod .. " + SHIFT + UP",
    hl.dsp.window.resize({ x = 0, y = -50 }),
    { description = "Resize up" }
)

hl.bind(
    mainMod .. " + SHIFT + DOWN",
    hl.dsp.window.resize({ x = 0, y = 50 }),
    { description = "Resize down" }
)

-- Move windows
hl.bind(
    mainMod .. " + CTRL + LEFT",
    hl.dsp.window.move({ direction = "l" }),
    { description = "Move window left" }
)

hl.bind(
    mainMod .. " + CTRL + RIGHT",
    hl.dsp.window.move({ direction = "r" }),
    { description = "Move window right" }
)

hl.bind(
    mainMod .. " + CTRL + UP",
    hl.dsp.window.move({ direction = "u" }),
    { description = "Move window up" }
)

hl.bind(
    mainMod .. " + CTRL + DOWN",
    hl.dsp.window.move({ direction = "d" }),
    { description = "Move window down" }
)

-- Swap windows
hl.bind(
    mainMod .. " + ALT + LEFT",
    hl.dsp.window.swap({ direction = "l" }),
    { description = "Swap window left" }
)

hl.bind(
    mainMod .. " + ALT + RIGHT",
    hl.dsp.window.swap({ direction = "r" }),
    { description = "Swap window right" }
)

hl.bind(
    mainMod .. " + ALT + UP",
    hl.dsp.window.swap({ direction = "u" }),
    { description = "Swap window up" }
)

hl.bind(
    mainMod .. " + ALT + DOWN",
    hl.dsp.window.swap({ direction = "d" }),
    { description = "Swap window down" }
)

-- Applications
hl.bind(
    mainMod .. " + D",
    hl.dsp.exec_cmd("pkill rofi || rofi -show run"),
    { description = "App launcher" }
)

hl.bind(
    mainMod .. " + B",
    hl.dsp.exec_cmd('xdg-open "https://"'),
    { description = "Open default browser" }
)

hl.bind(
    mainMod .. " + RETURN",
    hl.dsp.exec_cmd(terminal),
    { description = "Open terminal" }
)

-- Gestures
hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace",
})

hl.gesture({
    fingers = 3,
    direction = "up",
    action = "cursorZoom",
    zoom_level = "1.5",
    mode = "mult",
})

hl.gesture({
    fingers = 3,
    direction = "down",
    action = "cursorZoom",
    zoom_level = "1.5",
    mode = "mult",
})

hl.gesture({
    fingers = 4,
    direction = "up",
    action = function()
        hl.exec_cmd("sh ~/.config/hypr/scripts/OverviewToggle.sh")
    end,
})

hl.gesture({
    fingers = 4,
    direction = "down",
    action = "float",
})

-- Layer rules
hl.layer_rule({
    match = { namespace = "rofi" },
    blur = true,
    ignore_alpha = 0,
    animation = "slide",
})

hl.layer_rule({
    match = { namespace = "notifications" },
    blur = true,
    ignore_alpha = 0,
    animation = "slide",
})

hl.layer_rule({
    match = { namespace = "quickshell:overview" },
    blur = true,
    ignore_alpha = 0.5,
})

hl.layer_rule({
    match = { namespace = "quickshell:expose" },
    dim_around = true,
    blur = true,
    ignore_alpha = 0,
    xray = true,
})

hl.layer_rule({
    match = { namespace = "wallpaper" },
    blur = true,
    ignore_alpha = 0,
})

hl.layer_rule({
    match = { namespace = "swaync-notification-window" },
    blur = true,
    ignore_alpha = 0,
})

hl.layer_rule({
    match = { namespace = "com.aurora.keybinds_help" },
    blur = true,
    ignore_alpha = 0,
})

hl.layer_rule({
    match = { namespace = "logout_dialog" },
    blur = true,
    ignore_alpha = 0,
})

-- Window tags
hl.window_rule({
    match = {
        class = "^([Ff]irefox|org.mozilla.firefox|[Ff]irefox-esr|[Ff]irefox-bin)$",
    },
    tag = "+browser",
})

hl.window_rule({
    match = {
        class = "^(chromium)$",
    },
    tag = "+browser",
})

hl.window_rule({
    match = {
        class = "^(kitty|kitty-dropterm)$",
    },
    tag = "+terminal",
})

hl.window_rule({
    match = {
        class = "^([Tt]hunar|org.gnome.Nautilus|[Pp]cmanfm-qt)$",
    },
    tag = "+file-manager",
})

-- Window behavior
hl.window_rule({
    match = {
        class = "^(mpv|com.github.rafostar.Clapper)$",
    },
    float = true,
})

hl.window_rule({
    match = {
        class = "^(qalculate-gtk|[Qq]alculate-gtk)$",
    },
    float = true,
})

hl.window_rule({
    match = {
        class = "^(zoom|Zoom|onedriver|onedriver-launcher)$",
    },
    float = true,
})

-- Opacity
hl.window_rule({
    match = { tag = "browser" },
    opacity = "0.99 0.8",
})

hl.window_rule({
    match = { tag = "terminal" },
    opacity = "0.9 0.7",
})

hl.window_rule({
    match = { tag = "file-manager" },
    opacity = "0.9 0.8",
})

-- Multimedia
hl.window_rule({
    match = { class = "^(mpv|vlc)$" },
    no_blur = true,
    opacity = "1.0",
})

-- Fullscreen applications prevent idle
hl.window_rule({
    match = { fullscreen = true },
    idle_inhibit = "fullscreen",
})

-- Startup
hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")
    hl.exec_cmd("quickshell -c waybar-island")
    hl.exec_cmd("quickshell -c pill")
    hl.exec_cmd("quickshell -c launcher")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("kitty")
    hl.exec_cmd("code /etc/nixos")
end)