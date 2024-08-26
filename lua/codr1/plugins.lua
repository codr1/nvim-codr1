local plugins = {
  {
    "vim-crystal/vim-crystal",
    ft = "crystal",
    lazy = true,
    config = function (_)
      vim.g.crystal_auto_format = 1
    end
  },

  -- ChatGPT
  {
    "jackMort/ChatGPT.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim"
    },
    config = function ()
      require("chatgpt").setup({
        -- TODO: Figure out how to make LastPass CLI (lpass) stay logged in for a reasonable amount of time
        -- api_key_cmd = "lpass show 7048876137383249588 --password",
        api_key_cmd = "echo $OPENAI_API_KEY"

      })
    end,
  },


  -- Claude.vim 
  {
    "pasky/claude.vim",
    lazy = false,
    config = function()
      -- Load API key from environment variable
      local api_key = os.getenv("ANTHROPIC_API_KEY")
      if api_key then
        vim.g.claude_api_key = api_key
      else
        vim.notify("ANTHROPIC_API_KEY environment variable is not set", vim.log.levels.WARN)
      end

      -- Add keymaps
      vim.keymap.set("v", "<leader>Ci", ":'<,'>ClaudeImplement ", { noremap = true, desc = "Claude Implement" })
      vim.keymap.set("n", "<leader>Cc", ":ClaudeChat<CR>", { noremap = true, silent = true, desc = "Claude Chat" })
    end,
  },

  -- gp.nvim - collection of different LLMs
  {
    "robitx/gp.nvim",
    lazy = false,
    config = function()
      local conf = {
        providers = {
          openai = { 
            endpoint = "https://api.openai.com/v1/chat/completions",
            secret = os.getenv("OPENAI_API_KEY"),
          },
          anthropic = {
            endpoint = "https://api.anthropic.com/v1/messages",
            secret = os.getenv("ANTHROPIC_API_KEY"),
		      },
        },

      }
      require("gp").setup(conf)

        -- Setup shortcuts here (see Usage > Shortcuts in the Documentation/Readme)
    end,
  },


}
return plugins
