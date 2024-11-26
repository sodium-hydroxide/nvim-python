-- cmp.lua
--[[
 * @brief Manages code completion for Python using nvim-cmp
 * @module nvim-python.cmp
 *
 * This module configures intelligent code completion for Python, combining
 * multiple sources like LSP suggestions, snippets, and buffer text. It includes
 * Python-specific enhancements and snippets for common patterns.
--]]
local M = {}

--[[
 * @brief Sets up Python-specific snippets and completion sources
 * @local
 *
 * Configures snippets for common Python patterns and structures like:
 * - Main function blocks
 * - Class definitions
 * - Function definitions with docstrings
 * - Common Python imports
--]]
local function setup_snippets()
    local luasnip = require('luasnip')

    -- Load VSCode-style snippets
    require("luasnip.loaders.from_vscode").lazy_load({
        paths = { "./snippets/python" },
        include = { "python" },
    })

    -- Add custom Python-specific snippets
    luasnip.add_snippets("python", {
        -- Main block snippet
        luasnip.snippet("main", {
            luasnip.text_node({'if __name__ == "__main__":', '    '}),
            luasnip.insert_node(0),
        }),

        -- Class definition with docstring
        luasnip.snippet("class", {
            luasnip.text_node("class "),
            luasnip.insert_node(1, "ClassName"),
            luasnip.text_node({":", '    """'}),
            luasnip.insert_node(2, "Class description"),
            luasnip.text_node({'"""', "    "}),
            luasnip.insert_node(0),
        }),

        -- Function definition with docstring
        luasnip.snippet("def", {
            luasnip.text_node("def "),
            luasnip.insert_node(1, "function_name"),
            luasnip.text_node("("),
            luasnip.insert_node(2),
            luasnip.text_node({"):", '    """'}),
            luasnip.insert_node(3, "Function description"),
            luasnip.text_node({'"""', "    "}),
            luasnip.insert_node(0),
        }),

        -- Import snippet
        luasnip.snippet("imp", {
            luasnip.text_node("import "),
            luasnip.insert_node(0),
        }),
    })
end

--[[
 * @brief Formats completion items for better display
 * @param entry The completion entry
 * @param item The vim completion item
 * @return The formatted completion item
 * @local
--]]
local function format_completion_item(entry, item)
    -- Add source indicators
    item.menu = ({
        nvim_lsp = "[LSP]",
        luasnip = "[Snippet]",
        buffer = "[Buffer]",
        path = "[Path]",
    })[entry.source.name]

    -- Enhance Python-specific completions
    if entry.source.name == "nvim_lsp" then
        if item.kind == "Function" then
            -- Add parentheses to function completions
            item.abbr = item.abbr .. "()"
        elseif item.kind == "Class" then
            -- Add special formatting for class completions
            item.kind = "🔷 " .. item.kind
        elseif item.kind == "Method" then
            -- Add special formatting for method completions
            item.kind = "📎 " .. item.kind
        end
    end

    return item
end

--[[
 * @brief Default completion configuration
 * @local
 *
 * Configures completion behavior including:
 * - Key mappings for navigation and selection
 * - Source priorities (LSP > Snippets > Path > Buffer)
 * - Sort ordering based on multiple factors
 * - Special handling for Python completions
--]]
local default_cmp_config = {
    -- Enable snippet support
    snippet = {
        expand = function(args)
            require('luasnip').lsp_expand(args.body)
        end,
    },

    -- Configure completion window behavior
    window = {
        completion = {
            winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None",
            col_offset = -3,
            side_padding = 0,
        },
    },

    -- Key mappings for completion
    mapping = {
        ['<C-p>'] = function(fallback)
            local cmp = require('cmp')
            if cmp.visible() then
                cmp.select_prev_item()
            else
                fallback()
            end
        end,
        ['<C-n>'] = function(fallback)
            local cmp = require('cmp')
            if cmp.visible() then
                cmp.select_next_item()
            else
                fallback()
            end
        end,
        ['<C-d>'] = require('cmp').mapping.scroll_docs(-4),
        ['<C-f>'] = require('cmp').mapping.scroll_docs(4),
        ['<C-Space>'] = require('cmp').mapping.complete(),
        ['<C-e>'] = require('cmp').mapping.close(),
        ['<CR>'] = require('cmp').mapping.confirm({
            behavior = require('cmp').ConfirmBehavior.Replace,
            select = true,
        }),
        ['<Tab>'] = function(fallback)
            local cmp = require('cmp')
            local luasnip = require('luasnip')
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            else
                fallback()
            end
        end,
        ['<S-Tab>'] = function(fallback)
            local cmp = require('cmp')
            local luasnip = require('luasnip')
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end,
    },

    -- Configure completion sources and their priorities
    sources = {
        {
            name = 'nvim_lsp',
            priority = 1000,
            entry_filter = function(entry, ctx)
                -- Filter out certain completions for a cleaner experience
                local kind = require('cmp.types').lsp.CompletionItemKind[entry:get_kind()]
                if kind == "Text" then
                    return false
                end
                return true
            end
        },
        { name = 'luasnip',  priority = 750 },
        { name = 'path',     priority = 500 },
        { name = 'buffer',   priority = 250 },
    },

    -- Configure how completions are sorted
    sorting = {
        comparators = {
            require('cmp').config.compare.exact,
            require('cmp').config.compare.score,
            require('cmp').config.compare.recently_used,
            require('cmp').config.compare.locality,
            require('cmp').config.compare.kind,
            require('cmp').config.compare.length,
        },
    },

    -- Format completion items
    formatting = {
        format = format_completion_item,
    },

    -- Configure experimental features
    experimental = {
        -- Show the completion kind in a native way
        native_menu = false,
        -- Enable ghost text preview
        ghost_text = true,
    },
}

--[[
 * @brief Sets up code completion for Python
 * @param opts table Configuration options from main setup
--]]
M.setup = function(_)
    -- First, set up our custom snippets
    setup_snippets()

    -- Then configure nvim-cmp with our settings
    require('cmp').setup(default_cmp_config)

    -- Set up buffer-specific completion sources for Python files
    require('cmp').setup.filetype('python', {
        sources = {
            { name = 'nvim_lsp', priority = 1000 },
            { name = 'luasnip',  priority = 750 },
            { name = 'path',     priority = 500 },
            { name = 'buffer',   priority = 250 },
        }
    })
end

return M
