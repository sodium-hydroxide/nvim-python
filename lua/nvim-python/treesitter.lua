-- treesitter.lua
--[[
 * @brief Manages Python syntax highlighting and code navigation via Treesitter
 * @module nvim-python.treesitter
 *
 * This module configures Treesitter for Python, providing advanced syntax
 * highlighting and code navigation features. It includes smart text objects
 * for Python-specific constructs like functions and classes, and enables
 * structural navigation of your code.
--]]
local M = {}

--[[
 * @brief Default Treesitter configuration for Python
 * @local
 *
 * The configuration includes:
 * - Enhanced syntax highlighting with Python-specific rules
 * - Smart indentation based on code structure
 * - Incremental selection based on syntax tree
 * - Text objects for Python constructs
 * - Movement commands for navigating between functions and classes
--]]
local default_ts_config = {
    ensure_installed = { "python" },

    -- Syntax highlighting configuration
    highlight = {
        enable = true,
        -- Disable vim regex highlighting in favor of treesitter
        additional_vim_regex_highlighting = false,

        -- Custom highlights for Python-specific syntax
        custom_captures = {
            -- Special highlighting for Python builtins
            ["function.builtin"] = "Special",
            -- Make class definitions stand out
            ["class.definition"] = "Type",
            -- Highlight decorators distinctly
            ["decorator"] = "PreProc",
            -- Special handling for f-string components
            ["string.special"] = "SpecialChar",
            -- Highlight self/cls parameters
            ["variable.parameter.self"] = "Identifier",
        },
    },

    -- Smart indentation based on syntax tree
    indent = {
        enable = true,
    },

    -- Incremental selection based on syntax nodes
    incremental_selection = {
        enable = true,
        keymaps = {
            -- Start selecting the current node
            init_selection = "gnn",
            -- Increment to the bigger outer node
            node_incremental = "grn",
            -- Increment to the entire scope (e.g., entire function)
            scope_incremental = "grc",
            -- Decrement to the smaller node
            node_decremental = "grm",
        },
    },

    -- Text objects for smart selection
    textobjects = {
        -- Selection based on syntax nodes
        select = {
            enable = true,
            -- Look ahead for targets
            lookahead = true,
            -- Include commented nodes in selection
            include_surrounding_whitespace = false,

            keymaps = {
                -- Python-specific text objects
                ["af"] = "@function.outer",  -- Select entire function
                ["if"] = "@function.inner",  -- Select function body
                ["ac"] = "@class.outer",     -- Select entire class
                ["ic"] = "@class.inner",     -- Select class body
                ["ad"] = "@decorator.outer", -- Select entire decorator
                ["id"] = "@decorator.inner", -- Select decorator arguments
            },
        },

        -- Movement between syntax nodes
        move = {
            enable = true,
            -- Create jumplist entries for movements
            set_jumps = true,

            goto_next_start = {
                ["]f"] = "@function.outer",  -- Go to next function start
                ["]c"] = "@class.outer",     -- Go to next class start
                ["]d"] = "@decorator.outer", -- Go to next decorator
            },
            goto_next_end = {
                ["]F"] = "@function.outer",  -- Go to next function end
                ["]C"] = "@class.outer",     -- Go to next class end
                ["]D"] = "@decorator.outer", -- Go to next decorator end
            },
            goto_previous_start = {
                ["[f"] = "@function.outer",  -- Go to previous function start
                ["[c"] = "@class.outer",     -- Go to previous class start
                ["[d"] = "@decorator.outer", -- Go to previous decorator
            },
            goto_previous_end = {
                ["[F"] = "@function.outer",  -- Go to previous function end
                ["[C"] = "@class.outer",     -- Go to previous class end
                ["[D"] = "@decorator.outer", -- Go to previous decorator end
            },
        },

        -- Smart swapping of nodes
        swap = {
            enable = true,
            swap_next = {
                ["<leader>a"] = "@parameter.inner", -- Swap with next parameter
            },
            swap_previous = {
                ["<leader>A"] = "@parameter.inner", -- Swap with previous parameter
            },
        },
    },
}

--[[
 * @brief Sets up Treesitter for Python
 * @param opts table Configuration options from main setup
--]]
M.setup = function(_)
    -- Load the Treesitter configurations module
    require("nvim-treesitter.configs").setup(default_ts_config)

    -- Set up Python-specific fold settings
    vim.opt_local.foldmethod = "expr"
    vim.opt_local.foldexpr = "nvim_treesitter#foldexpr()"

    -- Start with all folds open
    vim.opt_local.foldenable = false
end

return M
