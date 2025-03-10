-- /home/vess/.config/nvim/lua/codr1/debug.lua
-- Debug configurations for various languages

-- Rust debugging configuration using CodeLLDB
local dap = require "dap"

dap.adapters.codelldb = {
    type = "server",
    port = "${port}",
    executable = {
        command = "codelldb", -- Ensure this binary is in your PATH (installed via Mason)
        args = { "--port", "${port}" },
    },
}

dap.configurations.rust = {
    {
        name = "Launch Rust executable",
        type = "codelldb",
        request = "launch",
        program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/target/debug/", "file")
        end,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
        args = {},
    },
}

-- Future debugging configurations for C, TypeScript, Go, Python, etc. can be added here.
--
--
--
--
--
-- https://github.com/theHamsta/nvim-dap-virtual-text
