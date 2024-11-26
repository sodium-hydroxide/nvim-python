-- lsp.lua
--[[
 * @brief Manages Python LSP (Language Server Protocol) configuration using Pyright
 * @module nvim-python.lsp
 *
 * This module sets up Pyright as the Python language server, configuring it to work
 * with virtual environments and providing intelligent code analysis. It includes
 * default settings that balance performance with helpful feedback.
--]]
local M = {}

--[[
 * @brief Default configuration for the Pyright language server
 * @local
 *
 * These settings configure Pyright for a balance of performance and functionality:
 * - basic type checking provides good catching of common errors
 * - autoSearchPaths helps find imports in the project
 * - useLibraryCodeForTypes enables better type information from libraries
--]]
local default_pyright_config = {
    settings = {
        python = {
            analysis = {
                typeCheckingMode = "basic",
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = "workspace",
                diagnosticSeverityOverrides = {
                    -- Customize which types of issues are reported and how
                    reportGeneralTypeIssues = "warning",
                    reportOptionalMemberAccess = "information",
                    reportOptionalSubscript = "warning",
                    reportPrivateImportUsage = "information"
                }
            }
        }
    }
}

--[[
 * @brief Sets up keybindings for LSP functionality in Python buffers
 * @param bufnr number The buffer number to attach keybindings to
 * @local
 *
 * Configures standard LSP keybindings for:
 * - Code navigation (definitions, references)
 * - Information display (hover documentation)
 * - Code modification (rename symbols)
 * - Diagnostic navigation
--]]
local function setup_keymaps(bufnr)
    local opts = { noremap=true, silent=true, buffer=bufnr }

    -- Navigation mappings
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)

    -- Information display
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)

    -- Code modification
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)

    -- Diagnostic navigation
    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
    vim.keymap.set('n', '<leader>dl', vim.diagnostic.setloclist, opts)
    vim.keymap.set('n', '<leader>df', vim.diagnostic.open_float, opts)
end

--[[
 * @brief Sets up Python LSP with Pyright
 * @param opts table Configuration options from main setup
 * @see M.options in init.lua for available options
--]]
M.setup = function(opts)
    local lspconfig = require('lspconfig')
    local util = require('nvim-python.utils')

    -- First, determine the Python path, respecting configuration hierarchy:
    -- 1. User-specified path
    -- 2. Virtual environment path
    -- 3. System Python path
    local python_path = opts.python_path or
                       (opts.venv_path and util.get_python_path()) or
                       vim.fn.exepath('python3')

    -- Merge default config with any user overrides
    local config = vim.tbl_deep_extend("force", default_pyright_config, {
        -- Configure the Python path before server initialization
        before_init = function(_, config)
            config.settings.python.pythonPath = python_path
        end,

        -- Set up buffer-local configurations when the server attaches
        on_attach = function(client, bufnr)
            setup_keymaps(bufnr)

            -- Enable document formatting if requested
            client.server_capabilities.documentFormattingProvider = opts.format_on_save

            -- Set up workspace folders if available
            if client.server_capabilities.workspace then
                client.workspace.configuration = true
            end
        end,

        -- Additional capabilities for better integration with nvim-cmp
        capabilities = require('cmp_nvim_lsp').default_capabilities()
    })

    -- Finally, initialize Pyright with our configuration
    lspconfig.pyright.setup(config)
end

return M
