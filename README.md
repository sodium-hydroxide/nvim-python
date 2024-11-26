# Complete Python Environment for Vim



## Installation Via Lazy

```lua
{
    "sodium-hydroxide/nvim-python",
    dependencies = {
        "neovim/nvim-lspconfig",
        "jose-elias-alvarez/null-ls.nvim",
        "nvim-treesitter/nvim-treesitter",
        "hrsh7th/nvim-cmp",
        "L3MON4D3/LuaSnip",
    },
    config = function()
        require("nvim-python").setup({
            -- Optional: override default options
            venv_path = "~/.venv",
            format_on_save = true
        })
    end
}
```
