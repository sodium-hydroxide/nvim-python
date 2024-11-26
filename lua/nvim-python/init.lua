local M = {}

--[[
 * @brief Configuration options for nvim-python
 * @field venv_path string Path to virtualenv directory
 * @field python_path string|nil Optional override for Python interpreter path
 * @field features table Feature flags for different components
 * @field format_on_save boolean Whether to format Python files on save
--]]
M.options = {
    venv_path = vim.fn.expand("~/.venv"),
    python_path = nil,
    features = {
        lsp = true,
        formatter = true,
        treesitter = true,
        completion = true
    },
    format_on_save = true
}

--[[
 * @brief Checks for required Python development dependencies
 * @return table Dependencies status with boolean flags
--]]
local function check_dependencies()
    local utils = require("nvim-python.utils")
    local deps = {
        python = utils.command_exists("python3"),
        pip = utils.command_exists("pip3"),
        pyright = utils.command_exists("pyright-langserver"),
        ruff = utils.command_exists("ruff"),
    }

    if vim.fn.executable(M.options.venv_path .. "/bin/python3") == 1 then
        deps.using_venv = true
    end

    return deps
end

--[[
 * @brief Sets up enabled features based on configuration
 * @local
--]]
local function setup_features()
    if M.options.features.lsp then
        require("nvim-python.lsp").setup(M.options)
    end

    if M.options.features.formatter then
        require("nvim-python.formatter").setup(M.options)
    end

    if M.options.features.treesitter then
        require("nvim-python.treesitter").setup()
    end

    if M.options.features.completion then
        require("nvim-python.cmp").setup()
    end
end

--[[
 * @brief Main setup function for nvim-python
 * @param opts table|nil Optional configuration overrides
 * @see M.options For available configuration options
--]]
M.setup = function(opts)
    M.options = vim.tbl_deep_extend("force", M.options, opts or {})

    -- Check required plugins
    local has_required_plugins = pcall(require, "lspconfig")
        and pcall(require, "null-ls")
        and pcall(require, "nvim-treesitter")
        and pcall(require, "cmp")

    if not has_required_plugins then
        vim.notify(
            "nvim-python requires: lspconfig, null-ls, nvim-treesitter, and nvim-cmp",
            vim.log.levels.ERROR
        )
        return
    end

    -- Dependency check
    local deps = check_dependencies()
    if not (deps.python and deps.pyright and deps.ruff) then
        local utils = require("nvim-python.utils")
        local pm = utils.detect_package_manager()

        vim.notify(
            "Missing dependencies. Please install:\n" ..
            "1. Python 3: " .. (pm == "brew" and "brew install python" or "apt install python3") .. "\n" ..
            "2. Pyright: npm install -g pyright\n" ..
            "3. Ruff: pip install ruff",
            vim.log.levels.WARN
        )
    end

    setup_features()
end

return M
