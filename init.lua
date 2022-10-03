vim.cmd([[
    set tabstop=4
    set expandtab
    set shiftwidth=4
    set smarttab

    let mapleader = "<space>"

    set number
]])

map = vim.keymap.set

require('packer').startup(function(use)
    -- Packer can manage itself
    use 'wbthomason/packer.nvim'

    -- Highlighting
    use {
        'nvim-treesitter/nvim-treesitter',
        run = ':TSUpdate',
        config = function()
            require('nvim-treesitter.configs').setup {
                ensure_installed = { "c", "lua", "zig" },
                highlight = { enable = true },
                indent = { enable = true }
            }
        end
    }
    -- Show contexts
    use { 'nvim-treesitter/nvim-treesitter-context' }

    -- use {
    --     "smjonas/snippet-converter.nvim",
    --     config = function()
    --         local template = {
    --             sources = {
    --                 ultisnips = {
    --                     vim.fn.stdpath("config") .. "/UltiSnips",
    --                 },
    --             },
    --             output = {
    --                 -- Specify the output formats and paths
    --                 vscode_luasnip = {
    --                     vim.fn.stdpath("config") .. "/luasnip_snippets",
    --                 },
    --             },
    --         }

    --         require("snippet_converter").setup {
    --             templates = { template },
    --         }
    --     end
    -- }

    -- Use to change surrounding chars/add
    -- cs"' (no i needed)
    -- ys(...)
    -- e.g. ysw"
    use { "tpope/vim-surround" }

    -- Highlights instances of letters on a line for easier f[x]
    -- TODO: Maybe remove now that we have hop.nvim?
    use { "unblevable/quick-scope" }

    use {
        'phaazon/hop.nvim',
        branch = 'v2',
        config = function()
            local hop = require('hop')

            hop.setup {
                -- Keys used for the hints!
                keys = 'etovxqpdygfblzhckisuran'
            }

            map(
                { "n", "v" },
                "<Space><Space>",
                hop.hint_patterns,
                { desc = "Hop to a pattern!" }
            )
            map(
                "n",
                "<Space>f",
                function()
                    hop.hint_patterns { current_line_only = true }
                end,
                { desc = "Hop to a pattern inline!" }
            )
        end
    }

    -- Proof Assistant for interactive Coq development
    use { "whonore/Coqtail",
        setup = function()
            vim.g.coqtail_nomap = 1
        end,
        config = function()
            vim.api.nvim_set_hl(0, "CoqtailChecked", { bg = "#353b45" })
            vim.api.nvim_set_hl(0, "CoqtailSent", { bg = "#333333" })
            map("n", "<Space>cl", "<Plug>CoqToLine", { desc = "Evaluate Coq to line" })
        end
    }

    -- Theme
    use { 'sam4llis/nvim-tundra',
        config = function()
            vim.opt.background = 'dark'
            vim.cmd('colorscheme tundra')
        end,
    }

    -- Indent guides
    use "lukas-reineke/indent-blankline.nvim"

    -- LSP Support
    use { "neovim/nvim-lspconfig",
        config = function()
            local lspconfig = require("lspconfig")

            lspconfig.zls.setup {}

            lspconfig.sumneko_lua.setup {
                settings = {
                    Lua = {
                        diagnostics = {
                            globals = { "vim" },
                        },
                        workspace = {
                            library = {
                                [vim.fn.expand "$VIMRUNTIME/lua"] = true,
                                [vim.fn.expand "$VIMRUNTIME/lua/vim/lsp"] = true,
                            },
                            maxPreload = 100000,
                            preloadFileSize = 10000,
                        },
                    },
                },
            }

            vim.keymap.set("n", "<space>ca", vim.lsp.buf.code_action, { desc = "Execute code action." })
            vim.keymap.set("n", "<space>ce", vim.lsp.buf.hover, { desc = "LSP hover action." })
        end,
    }

    -- LaTeX
    use { "lervag/vimtex",
        config = function()
            vim.g.tex_flavor = 'latex'
            vim.g.vimtex_view_method = 'zathura'
            vim.g.vimtex_quickfix_mode = 0
        end
    }

    -- Uses the sign column line left of line numbers for git info
    use {
        'lewis6991/gitsigns.nvim',
        config = function()
            -- Always show the column for consistent UI
            vim.g.signcolumn = "yes"

            require('gitsigns').setup()
        end
    }

    -- Easy alignment
    use { "junegunn/vim-easy-align",
        setup = function()
            for _, mode in ipairs({"n", "x"}) do
                vim.api.nvim_set_keymap(
                    mode,
                    "ga",
                    "<Plug>(EasyAlign)",
                    { noremap = false , silent = false }
                )
            end
        end
    }

    -- Preview lines when you do :[line_number]
    use { "nacro90/numb.nvim",
        event = "BufRead",
        config = function()
            require("numb").setup()
        end
    }

    -- Can pop up a list of diagnostics
    use { "folke/trouble.nvim",
        requires = "kyazdani42/nvim-web-devicons",
        config = function()
            require("trouble").setup {
                -- your configuration comes here
                -- or leave it empty to use the default settings
                -- refer to the configuration section below
            }
        end
    }

    -- Show errors kinda like what you get from rustc but inline
    use { "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
        config = function()
            -- don't need dupes lol
            vim.diagnostic.config { virtual_text = false }

            require("lsp_lines").setup()

            vim.keymap.set(
                "n",
                "<Space>l",
                require('lsp_lines').toggle,
                { desc = "Toggle lsp_lines" }
            )
        end,

    }

    -- use { "kyazdani42/nvim-web-devicons",
    --   after = "ui",
    --   module = "nvim-web-devicons",
    --   config = function()
    --     -- require("plugins.configs.others").devicons()
    --   end,
    -- }

    -- use { "lukas-reineke/indent-blankline.nvim",
    --     opt = true,
    --     setup = function()
    --         -- require("core.lazy_load").on_file_open "indent-blankline.nvim"
    --         -- require("core.utils").load_mappings "blankline"
    --     end,
    --     config = function()
    --         -- require("plugins.configs.others").blankline()
    --     end,
    -- }

    use { "NvChad/nvim-colorizer.lua",
        opt = true,
        setup = function()
            -- require("core.lazy_load").on_file_open "nvim-colorizer.lua"
        end,
        config = function()
            -- require("plugins.configs.others").colorizer()
        end,
    }

    use { "williamboman/mason.nvim",
        config = function()
            require("mason").setup()
        end,
    }

    -- use { "L3MON4D3/LuaSnip" ,
    --     wants = "friendly-snippets",
    --     after = "nvim-cmp",
    --     config = function()
    --         luasnips = require("luasnip")
    --         luasnips.config.setup { enable_autosnippets = true }
    --         require("luasnip/loaders/from_vscode")
    --             .load ({
    --                 paths = vim.fn.stdpath("config") .. "/luasnip_snippets"
    --             })
    --     end
    -- }

    -- use { "rafamadriz/friendly-snippets",
    --     module = { "cmp", "cmp_nvim_lsp" },
    --     event = "InsertEnter",
    -- }

    use { "SirVer/ultisnips",
        setup = function()
            vim.g.UltiSnipsSnipeptsDir = vim.fn.stdpath("config") .. "/UltiSnips"
            -- let g:UltiSnipsSnippetsDir = "~/.vim/bundle/ultisnips/UltiSnips"
        end
    }

    use { "hrsh7th/nvim-cmp",
        -- after = "friendly-snippets",
        -- after = "LuaSnip",
        require = "quangnguyen30192/cmp-nvim-ultisnips",
        after = "ultisnips",
        setup = function()
            vim.opt.completeopt = {'menu', 'menuone', 'noselect'}
        end,

        config = function()
            require("plugins.cmp")
        end
    }

    -- use { "saadparwaiz1/cmp_luasnip",
    --     after = "LuaSnip",
    -- }

    use { "hrsh7th/cmp-nvim-lua",
        -- after = "cmp_luasnip",
    }

    use { "hrsh7th/cmp-nvim-lsp",
        after = "cmp-nvim-lua",
    }

    use { "hrsh7th/cmp-buffer",
        after = "cmp-nvim-lsp",
    }

    use { "hrsh7th/cmp-path",
        after = "cmp-buffer",
    }

    use("quangnguyen30192/cmp-nvim-ultisnips")

    -- misc plugins
    use { "windwp/nvim-autopairs",
        after = "nvim-cmp",
        config = function()
            -- require("plugins.configs.others").autopairs()
        end,
    }

    use { "goolord/alpha-nvim",
        after = "base46",
        disable = true,
        config = function()
            -- require "plugins.configs.alpha"
        end,
    }

    use { "numToStr/Comment.nvim",
        module = "Comment",
        keys = { "gc", "gb" },
        config = function()
            -- require("plugins.configs.others").comment()
        end,
        setup = function()
            -- require("core.utils").load_mappings "comment"
        end,
    }

    -- file managing , picker etc
    use { "kyazdani42/nvim-tree.lua",
        ft = "alpha",
        cmd = { "NvimTreeToggle", "NvimTreeFocus" },
        config = function()
            -- require "plugins.configs.nvimtree"
        end,
        setup = function()
            -- require("core.utils").load_mappings "nvimtree"
        end,
    }

    use { "nvim-telescope/telescope.nvim",
        cmd = "Telescope",
        requires = { { "nvim-lua/plenary.nvim" } },
        config = function()
            -- require "plugins.configs.telescope"
        end,
        setup = function()
            -- require("core.utils").load_mappings "telescope"
        end,
    }

    -- want this at the end after gui stuff apparently?
    use {
        "folke/which-key.nvim",
        config = function()
            require("which-key").setup { }
        end
    }

    -- Speed up deffered plugins
    use { "lewis6991/impatient.nvim" }
end)
