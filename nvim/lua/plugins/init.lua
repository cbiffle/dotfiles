-- File loaded from init.lua as the configuration for Lazy.

return {
    -- Snippets engine, required for autocomplete to be able to insert
    -- templatized completion snippets.
    {
        "L3MON4D3/LuaSnip",
    },
    -- Autocomplete
    {
        'hrsh7th/nvim-cmp',
        dependencies = { 'hrsh7th/cmp-nvim-lsp', 'hrsh7th/cmp-path', 'saadparwaiz1/cmp_luasnip' },
        config = function()
            -- Set completeopt to have a better completion experience
            -- :help completeopt
            -- menuone: popup even when there's only one match
            -- noinsert: Do not insert text until a selection is made
            -- noselect: Do not select, force user to select one from the menu
            vim.o.completeopt = "menuone,noinsert,noselect"

            -- Avoid showing extra messages when using completion
            vim.o.shortmess = vim.o.shortmess .. "c"
            local cmp = require'cmp'
            cmp.setup{
                completion = {
                    -- Do not pop up the popup until I ask.
                    autocomplete = false
                },
                -- This is important, or when you attempt to accept a
                -- completion it will fail.
                snippet = {
                    expand = function(args)
                        require("luasnip").lsp_expand(args.body)
                    end,
                },
                sources = {
                    { name = 'nvim_lsp' },
                    { name = 'path' },
                },
                mapping = {
                    -- Pop up the popup only when I ask for it.
                    ["<C-Space>"] = cmp.mapping.complete(),

                    -- Keys for moving between items in the popup
                    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
                    ["<Tab>"] = cmp.mapping.select_next_item(),

                    -- Accept item
                    ["<CR>"] = cmp.mapping.confirm({
                        behavior = cmp.ConfirmBehavior.Insert,
                        select = true,
                    }),
                }
            }
        end
    },

    -- General LSP configuration, not language-specific
    {
        'neovim/nvim-lspconfig',
        config = function()
            local bufopts = { noremap=true, silent=true }
            vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
            vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
            vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
            vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
            vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
            vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
            vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, bufopts)
            vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, bufopts)
            vim.keymap.set('n', ']d', vim.diagnostic.goto_next, bufopts)
            vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, bufopts)
            vim.keymap.set('n', '<leader>r', vim.lsp.buf.rename, bufopts)
            vim.keymap.set('n', '<leader>a', vim.lsp.buf.code_action, bufopts)
            vim.keymap.set('n', '<leader>f', function()
                vim.lsp.buf.format { async = true }
            end, bufopts)
            vim.keymap.set('v', '<leader>f', function()
                vim.lsp.buf.format { async = true }
            end, bufopts)
            vim.diagnostic.config({
                -- Insert floaty things to the right of problems.
                virtual_text = true,
                -- Display icony things in the sign column.
                signs = true,
                -- Change from neovim's default sort mode for signs, which tends
                -- to hide errors, to the one that should obviously be the
                -- default, which shows most severe in preference to least.
                severity_sort = true,
                -- Underline problems.
                underline = true,
                -- Border, but not extreme border, on popups.
                float = { border = "single" },
            })
            -- Unicode: it's fun�
            local signs = { Error = "✖️ ", Warn = "⚠️ ", Hint = "💡", Info = "ℹ️ " }
            -- Wire each sign up to avoid repeating the sign_define call
            for type, icon in pairs(signs) do
                local hl = "DiagnosticSign" .. type
                vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
            end
        end
    },

    -- Treesitter provides better parsing than vim's historical "regexes can
    -- parse any language right" stuff. It represents an intermediate stage
    -- between that old tech, and LSP-generated semantic markup.
    --
    -- Probably the best explanation I can find is:
    -- https://www.josean.com/posts/nvim-treesitter-and-textobjects
    {
        'nvim-treesitter/nvim-treesitter',
        -- Recompile grammars if required.
        build = ':TSUpdate',
        config = function()
            local configs = require('nvim-treesitter.configs')

            configs.setup({
                -- At minimum I'm going to need these grammars:
                ensure_installed = {
                    "rust",
                    "c",
                },
                highlight = {
                    -- Treesitter should be used to parse files for highlighting
                    -- purposes, overriding the historical stuff.
                    enable = true,
                },
            })
        end,
    },

    --{"lunarvim/darkplus.nvim"},
    --{
    --    "ellisonleao/gruvbox.nvim",
    --    priority = 1000,
    --    config = true,
    --    opts = {
    --        italic = {
    --            strings = false,
    --        },
    --    },
    --},
    { "catppuccin/nvim", name = "catppuccin", priority = 1000,
        opts = {
            -- Flavour to use when requested without a name suffix.
            flavour = "mocha",
            color_overrides = {
                frappe = {
                    -- I prefer an actually-black background
                    base = "#000000",
                },
                macchiato = {
                    -- I prefer an actually-black background
                    base = "#000000",
                },
                mocha = {
                    -- I prefer an actually-black background
                    base = "#000000",
                    mantle = "#2e2e3e",
                    crust = "#1e1e2e",
                    text = "#dde6f4",
                },
            },
            styles = {
                conditionals = {},
            },
            custom_highlights = function(colors)
                return {
                    -- Override the sign column to use the mantle color
                    SignColumn = { bg = colors.mantle },
                    -- Brighten up the status line on the focused pane.
                    StatusLine = { bg = colors.overlay0 },

                    -- I like my comments blue to exploit chromostereopsis.
                    Comment = {fg = colors.blue },

                    -- Weirdly, all signs default to black background by
                    -- default. Fix this:
                    DiagnosticSignError = { bg = colors.mantle },
                    DiagnosticSignWarn = { bg = colors.mantle },
                    DiagnosticSignInfo = { bg = colors.mantle },
                    DiagnosticSignHint = { bg = colors.mantle },

                    -- I like my macros visually set apart from everything else
                    -- a bit more than the default, and pink is underused in
                    -- the syntax themes.
                    Macro = { fg = colors.pink },
                    -- Teal sets the strings off from comments well enough for
                    -- me, visually.
                    String = { fg = colors.teal },
                    -- Playing with highlighting constants.
                    Constant = { style = {"italic"}},
                    -- By default the following things are distinguished by
                    -- color; I would prefer that they were mostly not
                    -- distinguished.
                    ["@property"] = { fg = colors.text },
                    ["@variable.member"] = { link = "@property" },
                    Function = {
                        -- just colors.text + bold looks a bit too bright
                        fg = colors.subtext1,
                        style = {"bold"},
                    },

                    -- I do not need function arguments colored differently
                    -- from other variables, thanks.
                    ["@parameter"] = { link = "@variable" },
                    ["@variable.parameter"] = { link = "@parameter" },

                    -- I do not need "builtin" functions and macros
                    -- distinguished from anything else, thank you.
                    ["@function.builtin"] = { link = "Function" },
                    ["@lsp.typemod.macro.defaultLibrary"] = { link = "Macro" },

                    -- Make macros, and also derive attributes, look like
                    -- macros.
                    ["@function.macro"] = { link = "Macro" },
                    ["@lsp.type.decorator"] = { link = "Macro" },
                    ["@lsp.mod.attribute"] = { link = "Macro" },

                    -- Disable default italics for module names because I find
                    -- it distracting.
                    ["@module"] = { style = {} },

                    -- Make the defining appearance of a variable slightly more
                    -- obvious. I'm doing this almost entirely to make closures
                    -- stand out, because neither treesitter nor rust-analyzer
                    -- give me many classes to go on to achieve this.
                    ["@lsp.typemod.variable.declaration"] = { fg = colors.green },
                    ["@lsp.typemod.parameter.declaration"] = { link = "@lsp.typemod.variable.declaration" },

                    -- this looks like an oversight upstream.
                    ["@lsp.mod.constant"] = { link = "Constant" },
                    -- Play with highlighting enum members differently from
                    -- constants.
                    ["@lsp.type.enumMember"] = {
                        style = {"bold"},
                    },
		    -- Just use keyword highlighting for self, thanks
		    ["@lsp.type.selfKeyword"] = { link = "Keyword" },
		    ["@variable.builtin"] = { link = "Keyword" },
                    -- Make ? more obvious.
                    ["@lsp.typemod.operator.controlFlow"] = {
                        fg = colors.red,
                        style = {"bold"},
                    },
                    -- Highlight all appearances of and uses of mutable
                    -- bindings. I'm not sure if I like this, I'm messing with
                    -- it.
                    ["@lsp.mod.mutable"] = {
                        style = {"underline"},
                    },
                    ["@lsp.typemod.variable.mutable"] = {
                        link = "@lsp.mod.mutable",
                    },

		    ["gitcommitSummary"] = { style = {"bold"}},
                }
            end,
            integrations = {
                native_lsp = {
                    -- By default catppuccin leaves most underlines as plain
                    -- underlines. Since I'm using a modern terminal, I've got
                    -- options!
                    underlines = {
                        -- Red squiggle for errors
                        errors = {"undercurl"},
                        -- Yellow squiggle for warnings
                        warnings = {"undercurl"},
                        -- Fine dots for hints and info
                        hints = {"underdashed"},
                        information = {"underdashed"},
                    },
                },
            },
        },
    },
}
