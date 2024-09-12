local options = {
    formatters_by_ft = {
        javascript = { "eslint_d" },
        typescript = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        typescriptreact = { "eslint_d" },
        c = { "clang_format" },
        cpp = { "clang_format" },
        python = { "black", "isort" },
        json = { "prettier" },
        lua = { "stylua" },
        css = { "prettier" },
        html = { "prettier" },
        yaml = { "prettier" },
    },
    formatters = {
        black = {
            prepend_args = { "--line-length", "120" },
        },
        clang_format = {
            prepend_args = { "-style=file:~/.config/nvim/codr1/formatter_configs/.clang-format" },
        },
        eslint_d = {
            prepend_args = {
                "--config",
                vim.fn.expand "~/.config/nvim/codr1/formatter_configs/eslint.config.js",
            },
        },
    },
}

-- Set up autoformatting on save
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    callback = function(args)
        require("conform").format { bufnr = args.buf }
    end,
})

-- format_on_save = {
--   -- These options will be passed to conform.format()
--   timeout_ms = 500,
--   lsp_fallback = true,
-- },

return options
