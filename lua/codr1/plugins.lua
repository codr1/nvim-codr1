local plugins = {
    {
        "vim-crystal/vim-crystal",
        ft = "crystal",
        lazy = true,
        config = function(_)
            vim.g.crystal_auto_format = 1
        end,
    },

    -- Mason is alrady inlcuded by NVChad.  However we want to add an ensure_installed clause so that
    -- it loads our favorite packages every time we pull this config on a new system, and we don't have
    -- to walk through the tUI by hand to install them
    {
        "williamboman/mason.nvim",
        opts = {
            -- Serves that are set up via lspconfig should be automatically installed
            automatic_installation = true,
        },
    },

    -- cmp is already included by NVChad.  However I really wanted to change the default key bindings.
    --   and apparenctly this is how you do it.  https://github.com/NvChad/NvChad/discussions/2832
    {
        "hrsh7th/nvim-cmp",
        opts = function()
            local cmp = require "cmp"
            local conf = require "nvchad.configs.cmp"
            --cmp.setup {
            --    mapping = {
            --       sources = cmp.config.sources {
            --            { name = "nvimai_cmp_source" }, -- This is optional but recommended
            --        },
            --    },
            --}
            conf.mapping = {
                -- this little section is just for nvim.ai
                --sources = cmp.config.sources {
                --    { name = "nvimai_cmp_source" }, -- This is optional but recommended
                --},
                ["<Up>"] = cmp.mapping.select_prev_item(),
                ["<Down>"] = cmp.mapping.select_next_item(),
                ["<Enter>"] = cmp.mapping.confirm {
                    behavior = cmp.ConfirmBehavior.Replace,
                    select = true,
                },
            }
            return conf
        end,
    },

    -- Glow - Markdown preview - https://github.com/ellisonleao/glow.nvim
    {
        "ellisonleao/glow.nvim",
        cmd = "Glow",
        config = function()
            local conf = {
                -- add any override config
                require("glow").setup {
                    width = 120,
                },
            }
        end,
    },

    {
        "tpope/vim-fugitive",
        event = "VeryLazy",
        config = function()
            -- Key mappings for common Fugitive commands
            vim.keymap.set("n", "<leader>gs", vim.cmd.Git)
            vim.keymap.set("n", "<leader>gw", ":Gwrite<CR>")
            vim.keymap.set("n", "<leader>gc", ":Git commit<CR>")
            vim.keymap.set("n", "<leader>gp", ":Git push<CR>")
            vim.keymap.set("n", "<leader>gl", ":Git pull<CR>")
            vim.keymap.set("n", "<leader>gd", ":Gdiff<CR>")
            vim.keymap.set("n", "<leader>gb", ":Git blame<CR>")
        end,
    },

    -- Flog - Git plugin
    {
        "rbong/vim-flog",
        lazy = true,
        cmd = { "Flog", "Flogsplit", "Floggit" },
        dependencies = {
            "tpope/vim-fugitive",
        },
    },

    -- remember.nvim - restore cursor position
    {
        "vladdoster/remember.nvim",
        lazy = false,
        config = function()
            require("remember").setup {}
        end,
    },

    -- undotree - awesome undo manager
    {
        "mbbill/undotree",
        lazy = false,
    },

    -- Custom cmp config to add arrow keymaps
    {},

    -- nvim.ai
    {
        "magicalne/nvim.ai",
        lazy = false,
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
        },
        config = function()
            local api_key = os.getenv "ANTHROPIC_API_KEY"
            local opts = {
                provider = "anthropic", -- You can configure your provider, model or keymaps here.
                anthropic = {
                    max_tokens = 100000,
                },
                ANTHROPIC_API_KEY = api_key,
                keymaps = {
                    toggle = "<leader>ac", -- Toggle chat dialog
                    inline_assist = "<leader>ai", -- Run InlineAssist command with prompt
                },
            }
            require("ai").setup(opts)
        end,
    },

    -- Claude.vimz
    {
        "pasky/claude.vim",
        lazy = false,
        config = function()
            -- Load API key from environment variable
            local api_key = os.getenv "ANTHROPIC_API_KEY"
            if api_key then
                vim.g.claude_api_key = api_key
            else
                vim.notify("ANTHROPIC_API_KEY environment variable is not set", vim.log.levels.WARN)
            end

            -- Add keymaps
            vim.keymap.set("v", "<leader>Ci", ":'<,'>ClaudeImplement ", { noremap = true, desc = "Claude Implement" })
            vim.keymap.set(
                "n",
                "<leader>Cc",
                ":ClaudeChat<CR>",
                { noremap = true, silent = true, desc = "Claude Chat" }
            )
        end,
    },

    -- Avante - Cursor-like AI experince
    {
        "yetone/avante.nvim",
        event = "VeryLazy",
        lazy = false,
        build = "make",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "stevearc/dressing.nvim",
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
            "zbirenbaum/copilot.lua", -- for providers='copilot'
            {
                -- support for image pasting
                "HakonHarnes/img-clip.nvim",
                event = "VeryLazy",
                opts = {
                    -- recommended settings
                    default = {
                        embed_image_as_base64 = false,
                        prompt_for_file_name = false,
                        drag_and_drop = {
                            insert_mode = true,
                        },
                    },
                },
            },
            {
                -- Make sure to set this up properly if you have lazy=true
                "MeanderingProgrammer/render-markdown.nvim",
                opts = {
                    file_types = { "markdown", "Avante" },
                },
                ft = { "markdown", "Avante" },
            },
        },
        opts = {
            --- @alias Provider "claude" | "openai" | "azure" | "gemini" | "cohere" | "copilot" | string
            provider = "claude",
            windows = {
                sidebar_header = {
                    align = "left",
                    rounded = "true",
                },
            },
        },
    },
}
return plugins
