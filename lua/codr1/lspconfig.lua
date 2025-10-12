-- load defaults i.e lua_lsp
local nvlsp = require "nvchad.configs.lspconfig"

local on_attach = nvlsp.on_attach
local on_init = nvlsp.on_init
local capabilities = nvlsp.capabilities

-- EXAMPLE
local servers = {
    "bashls",
    "clangd",
    "cssls",
    "html",
    "htmx",
    "jqls",
    "jsonls",
    "lua_ls",
    "sqls",
    "templ",
    "ts_ls",
}

-- lsps with default config
for _, lsp in ipairs(servers) do
    vim.lsp.config(lsp, {
        on_attach = nvlsp.on_attach,
        on_init = nvlsp.on_init,
        capabilities = nvlsp.capabilities,
    })
    vim.lsp.enable(lsp)
end

-- Custom setup for gopls
vim.lsp.config("gopls", {
    on_attach = nvlsp.on_attach,
    on_init = nvlsp.on_init,
    capabilities = nvlsp.capabilities,
    cmd = { "gopls" },
    filetypes = { "go", "gomod", "gowork" },
    root_dir = function(fname)
        -- Use vim.fs.find to locate the root directory
        local markers = { "go.work", "go.mod", ".git" }
        local root = vim.fs.root(fname, markers)
        return root or vim.loop.cwd()
    end,
    settings = {
        gopls = {
            completeUnimported = true,
            usePlaceholders = true,
            analyses = {
                unusedparams = true, -- correct spelling
            },
        },
    },
})
vim.lsp.enable "gopls"

-- Custom setup for pylsp
vim.lsp.config("pylsp", {
    on_attach = nvlsp.on_attach,
    on_init = nvlsp.on_init,
    capabilities = nvlsp.capabilities,
    settings = {
        pylsp = {
            plugins = {
                pycodestyle = {
                    maxLineLength = 120,
                },
            },
        },
    },
})
vim.lsp.enable "pylsp"

-- configuring single server, example: typescript
-- vim.lsp.config("ts_ls", {
--   on_attach = nvlsp.on_attach,
--   on_init = nvlsp.on_init,
--   capabilities = nvlsp.capabilities,
-- })
-- vim.lsp.enable("ts_ls")
