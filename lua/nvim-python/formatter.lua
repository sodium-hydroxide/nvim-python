-- formatter.lua
--[[
 * @brief Manages Python code formatting using Ruff
 * @module nvim-python.formatter
 *
 * This module configures Ruff as both a formatter and linter for Python code.
 * Ruff is chosen for its speed and compatibility with Black's formatting style,
 * while providing additional features like import sorting and code fixes.
--]]
local M = {}

--[[
 * @brief Default configuration for Ruff formatter
 * @local
 *
 * Configuration details:
 * - E: pycodestyle errors
 * - F: pyflakes
 * - W: pycodestyle warnings
 * - I: isort
 * - N: pep8-naming
 * - B: flake8-bugbear
 * - A: flake8-builtins
 * - C4: flake8-comprehensions
 * - UP: pyupgrade
 * - RUF: Ruff-specific rules
--]]
local default_ruff_config = {
    extra_args = {
        "--select=E,F,W,I,N,B,A,C4,UP,RUF",  -- Selected rule sets
        "--line-length=80",                   -- More conservative
        "--target-version=py37",              -- Minimum Python version
        "--fix",                              -- Apply fixes automatically
        "--unsafe-fixes",                     -- Enable advanced fixes
        "--extend-ignore=E203",               -- Ignore whitespace before ':' (Black compatibility)
    }
}

--[[
 * @brief Sets up Python formatting with Ruff
 * @param opts table Configuration options from main setup
 * @see M.options in init.lua for available options
--]]
M.setup = function(opts)
    local null_ls = require("null-ls")
    local utils = require("nvim-python.utils")

    -- Determine the Ruff command path, preferring virtual environment if available
    local ruff_cmd = opts.venv_path
        and (opts.venv_path .. "/bin/ruff")
        or "ruff"

    -- Configure both formatting and diagnostics through null-ls
    null_ls.setup({
        sources = {
            -- Formatter configuration
            null_ls.builtins.formatting.ruff.with({
                command = ruff_cmd,
                extra_args = default_ruff_config.extra_args,
            }),
            -- Diagnostic configuration (linting)
            null_ls.builtins.diagnostics.ruff.with({
                command = ruff_cmd,
                extra_args = default_ruff_config.extra_args,
                diagnostics_format = '#{m} [#{c}]', -- Include rule codes in messages
            })
        },
        -- Configure how formatting is handled
        on_attach = function(client, bufnr)
            -- Set up format on save if enabled
            if opts.format_on_save then
                vim.api.nvim_create_autocmd("BufWritePre", {
                    buffer = bufnr,
                    callback = function()
                        vim.lsp.buf.format({
                            timeout_ms = 2000,
                            bufnr = bufnr,
                        })
                    end,
                })
            end

            -- Add a command to manually format
            vim.api.nvim_buf_create_user_command(bufnr, "Format", function()
                vim.lsp.buf.format({
                    timeout_ms = 2000,
                    bufnr = bufnr,
                })
            end, { desc = "Format current buffer with Ruff" })
        end
    })
end

return M
