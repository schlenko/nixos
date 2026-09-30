package.path = os.getenv("HOME") .. "/.config/hypr/?.lua;" .. package.path

local modules = {
    "env",
    "settings",
    "animations",
    "monitors",
    "keybinds",
    "gestures",
    "rules",
    "autostart",
}

for _, name in ipairs(modules) do
    local ok, err = pcall(require, "modules." .. name)
    if not ok then
        print("[hyprland.lua] module '" .. name .. "' failed: " .. tostring(err))
    end
end