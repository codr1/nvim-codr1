local nvlsp = require "nvchad.configs.lspconfig"

local plugins = {

    {
        "ojroques/nvim-osc52",
        lazy = false,
        config = function()
            local osc52 = require "osc52"

            osc52.setup {
                max_length = 0, -- Maximum length of selection (0 for no limit)
                silent = false, -- Disable message when copied
                trim = false, -- Trim surrounding whitespaces before copy
            }

            -- Override vim's clipboard to use OSC52
            vim.api.nvim_create_autocmd("TextYankPost", {
                callback = function()
                    -- When yanking, automatically copy to clipboard
                    if vim.v.event.operator == "y" then
                        osc52.copy_register '"'
                    end
                end,
            })

            -- Connect the system clipboard to Neovim
            vim.opt.clipboard = "unnamedplus"
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

    -- NVIM-DAP - core debugging plugin
    {
        "jay-babu/mason-nvim-dap.nvim",
        config = function()
            require("mason-nvim-dap").setup {
                -- Enable automatic installation of debuggers for languages you need
                automatic_installation = true,
                -- Optionally, set up custom handlers if needed
                handlers = {},
            }
        end,
    },

    -- Debug UI for nvim-dap,
    {
        "rcarriga/nvim-dap-ui",
        dependencies = { "nvim-neotest/nvim-nio" }, -- nvim-nio is required by nvim-dap-ui
        config = function()
            require("dapui").setup {
                -- You can add custom configuration here if needed
            }
        end,
        lazy = true,
        cmd = { "DapUIToggle" },
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

    -- Git integration with vim-fugitive
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

    -- Rust.vim - Official Rust vim plugin - used for format on save
    {
        "rust-lang/rust.vim",
        ft = "rust",
        init = function()
            vim.g.rustfmt_autosave = 1
        end,
    },

    --Rust-tools.nvim - Official set of tools for Rust, including LSP, Debug, etc.
    {
        "simrat39/rust-tools.nvim",
        ft = "rust",
        dependencies = "neovim/nvim-lspconfig",

        opts = function()
            local options = {
                server = {
                    on_attach = nvlsp.on_attach,
                    capabilities = nvlsp.capabilities,
                },
            }
            return options
        end,

        config = function(_, opts)
            require("rust-tools").setup(opts)
        end,
    },

    -- Rust debugger DAP
    {
        "mfussenegger/nvim-dap",
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
            auto_suggestions_provider = "claude",
            claude = {
                temperature = 0,
                max_tokens = 8192,
            },
            windows = {
                sidebar_header = {
                    align = "left",
                    rounded = "true",
                },
            },
        },
    },

    -- Database plugin for interactive queries (vim-dadbod)
    {
        "tpope/vim-dadbod",
        lazy = true,
        cmd = { "DB", "DBUI" },
    },

    -- SQL auto-completion based on database schema (vim-dadbod-completion)
    {
        "kristijanhusak/vim-dadbod-completion",
        lazy = true,
        event = "InsertEnter",
    },
}
return plugins
