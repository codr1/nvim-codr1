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
        ensure_installed = {
            "codelldb",
            "gopls",
            "templ",
            "eslint_d",
            "typescript_language_server",
        },
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
                "HakonHarnes/img-clip.nvim", -- support for image pasting
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
                opts = { file_types = { "markdown", "Avante" } },
                ft = { "markdown", "Avante" },
            },
        },
        opts = {
            mode = "legacy",
            --- @alias Provider "claude" | "openai" | "azure" | "gemini" | "cohere" | "copilot" | string
            --- 1. Set Anthropic Claude as the AI provider (for both main and suggestions)
            provider = "claude",
            auto_suggestions_provider = "claude",
            --(NOTE: Using Claude for high-frequency auto suggestions is expensive)

            -- 2. Anthropic API settings
            claude = {
                timeout = 60000,
                -- temperature = 0,
                temperature = 1, -- temperature may only be set to 1 when thinking is enabled.
                max_tokens = 64000,
                thinking = { type = "enabled", budget_tokens = 16000 },
                disable_tools = false,
                model = "claude-sonnet-4-20250514", -- Using Claude 4 specifically.
            },

            -- 3. Gemini API settings - optimized for maximum performance in 2025
            gemini = {
                timeout = 120000, -- Extended timeout for complex operations
                model = "gemini-2.5-pro-preview-05-06", -- Latest Gemini model as of 2025
                temperature = 1.0, -- Maximum creative capability
            },

            -- Features Section
            features = {
                web_search = true,
                project_context = true,
                file_search = true,
            },

            --- Behaviour Tuning
            behaviour = {
                auto_suggestions = false, -- only on demand
                auto_focus_sidebar = true, -- jump into pane for review
                auto_apply_diff_after_generation = false, -- manual diff approval
                enable_token_counting = true, -- see real-time usage
                cursor_planning_mode = true, -- plan-apply workflow
                minimize_diff = false, -- do full context diffs
            },

            -- Tools Configuration
            tools = {
                disabled_tools = { "git_commit" },
                web_search = { provider = "tavily", max_results = 5, include_answer = true, timeout = 15000 },
                rag_service = {
                    enabled = true,
                    provider = "claude",
                    llm_model = "claude-sonnet-4",
                    embed_model = "nomic-embed-text",
                    host_mount = vim.env.HOME,
                },
                -- Alternative Gemini RAG configuration (disabled by default)
                -- To use, change the provider in rag_service to "gemini"
                gemini_rag = {
                    provider = "gemini",
                    llm_model = "gemini-2.5-pro-preview-05-06",
                    embed_model = "vertex-embed-text-2", -- Latest Google embedding model as of 2025
                    chunk_size = 4096, -- Enhanced chunk size for better context retention
                    chunk_overlap = 512, -- Increased overlap for improved context coherence
                    hybrid_search = true, -- Enables both semantic and keyword search
                    reranking = true, -- Post-processing to improve result relevance
                    max_sources = 15, -- Increased source limit for more comprehensive context
                },
                mcp = { enabled = true },
            },
            web_search_engine = {
                provider = "tavily",
                api_key = os.getenv "TAVILY_API_KEY",

                -- Additional settings:
                max_results = 5, -- Number of search results to retrieve (default: 5)
                include_answer = true, -- Include Tavily's summarized answer (default: true)
                include_images = false, -- Include images in search results (default: false)
                search_depth = "advanced", -- "basic" or "advanced" search depth (default: "basic")
                include_domains = {}, -- Array of domains to prioritize in search results
                exclude_domains = {}, -- Array of domains to exclude from search results
                timeout = 15000, -- Timeout in milliseconds (default: 15000)
                -- For specialized searches:
                search_type = "search", -- Can be "search" or "passage" (default: "search")
                search_bm25 = false, -- Enable BM25 vector search (default: false)
            },

            -- Persistent History
            history = {
                storage_path = vim.fn.stdpath "state" .. "/avante",
                max_tokens = 8192,
                carried_entry_count = 10,
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
