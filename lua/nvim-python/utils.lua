local M = {}

--[[
 * @brief Detects the system package manager (brew, apt, or dnf)
 * @return string|nil The detected package manager name or nil if none found
--]]
M.detect_package_manager = function()
    if vim.fn.executable('brew') == 1 then
        return 'brew'
    elseif vim.fn.executable('apt-get') == 1 then
        return 'apt'
    elseif vim.fn.executable('dnf') == 1 then
        return 'dnf'
    end
    return nil
end


--[[
 * @brief Checks if a command exists in the system PATH
 * @param cmd string The command to check for
 * @return boolean True if command exists, false otherwise
--]]
M.command_exists = function(cmd)
    return vim.fn.executable(cmd) == 1
end

--[[
 * @brief Gets the Python interpreter path, preferring virtualenv if available
 * @return string Path to the Python interpreter
--]]
M.get_python_path = function()
    local venv_python = vim.fn.expand("~/.venv/bin/python3")
    if vim.fn.executable(venv_python) == 1 then
        return venv_python
    end
    return vim.fn.exepath("python3")
end

return M
