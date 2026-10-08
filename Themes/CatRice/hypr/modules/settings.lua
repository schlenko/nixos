local section = require("modules.util").section

local util = require("modules.util")
local section, safe = util.section, util.safe

local plugin_dir = "/home/t/.local/share/hypr-plugins/"

section("plugins.load", function()
    safe(hl.plugin.load, plugin_dir .. "libhyprtasking.so")
    safe(hl.plugin.load, plugin_dir .. "libhyprbars.so")
end)

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
            workspace_back_and_forth = false,
            allow_workspace_cycles = false,
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

section("config.gestures", function()
    hl.config({
        gestures = {
            workspace_swipe_invert = false,
            workspace_swipe_forever = true,   
            workspace_swipe_distance = 100,   
            workspace_swipe_create_new = false, 
        },
    })
end)
local plugin_dir = "/home/t/.local/share/hypr-plugins/"

section("plugins.load", function()
    safe(hl.plugin.load, plugin_dir .. "libhyprtasking.so")
    safe(hl.plugin.load, plugin_dir .. "libhyprbars.so")
end)

section("config.hyprtasking", function()
    hl.config({
        plugin = {
            hyprtasking = {
                gestures = {
                    enabled = false,
                },
                exit_on_hovered = true,
                border_size = 0,
                gap_size = 0,
                bg_color = 0xff000000,

            },
        },
    })
end)

section("config.hyprbars", function()
    hl.config({
        plugin = {
            hyprbars = {
                bar_height = 24,
                bar_padding = 4,
                bar_button_padding = 6,
                bar_precedence_over_border = true,
                bar_part_of_window = true,

                bar_color = "rgba(0000001a)",
                bar_blur = true,

                bar_buttons_alignment = "left",

                bar_text_font = "Chivo",
                bar_text_weight = 800,
                bar_text_size = 13,
                col = { text = "rgba(c4a7e7ff)" },

                icon_on_hover = false,
            },
        },
    })

    hl.plugin.hyprbars.add_button({
        bg_color = "rgba(00000000)",
        fg_color = "rgba(c4a7e7ff)",
        size = 18,
        icon = "×",
        action = [[hyprctl dispatch 'hl.dsp.window.close()']],
    })

    hl.plugin.hyprbars.add_button({
        bg_color = "rgba(00000000)",
        fg_color = "rgba(c4a7e7ff)",
        size = 18,
        icon = "□",
        action = [[hyprctl dispatch 'hl.dsp.window.fullscreen()']],
    })
end)


section("config.overview_fix", function()
    local hidden = false

    local function waybar_toggle()
        hl.dispatch(hl.dsp.exec_cmd("pkill -SIGUSR1 waybar"))
    end

    local function set_ui(visible)
        hl.config({ plugin = { hyprbars = { enabled = visible } } })

        -- Only signal waybar when its state actually needs to change
        if visible == hidden then
            waybar_toggle()
            hidden = not visible
        end
    end

    -- Use this in your keybinds instead of calling hyprtasking.toggle directly
    function toggle_overview(mode)
        if hl.plugin.hyprtasking.is_active() then
            hl.plugin.hyprtasking.toggle(mode)
            set_ui(true)
        else
            set_ui(false)
            hl.plugin.hyprtasking.toggle(mode)
        end
    end

    -- Safety net for exits that bypass the wrapper (clicking a window,
    -- switching workspace)
    local function restore_ui()
        if not hl.plugin.hyprtasking.is_active() then
            set_ui(true)
        end
    end

    hl.on("window.active", restore_ui)
    hl.on("workspace.active", restore_ui)
end)