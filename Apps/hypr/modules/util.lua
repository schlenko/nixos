local M = {}

function M.section(name, fn)
    local ok, err = pcall(fn)
    if not ok then
        print("[hyprland.lua] section '" .. name .. "' failed: " .. tostring(err))
    end
end

function M.safe(fn, ...)
    local ok, err = pcall(fn, ...)
    if not ok then
        print("[hyprland.lua] " .. tostring(err))
    end
end

M.exec = hl.exec_cmd or function(cmd)
    hl.dispatch(hl.dsp.exec_cmd(cmd))
end

return M