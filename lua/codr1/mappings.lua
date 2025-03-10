local map = vim.keymap.set

map("n", "<leader>tt", function()
    require("base46").toggle_transparency()
end, { desc = "Toggle Transparency" })

map("n", "<leader>ut", function()
    vim.cmd.UndotreeToggle()
end, { desc = "Toggle UndoTree" })

--vim.keymap.set('n', '<leader>ut', vim.cmd.UndotreeToggle), {desc = "Toggle UndoTree"}

-- Debugging key bindings using function keys
vim.keymap.set("n", "<F5>", require("dap").continue, { desc = "Start/Continue Debugging" })
vim.keymap.set("n", "<F9>", require("dap").toggle_breakpoint, { desc = "Toggle Breakpoint" })
vim.keymap.set("n", "<F10>", require("dap").step_over, { desc = "Step Over" })
vim.keymap.set("n", "<F11>", require("dap").step_into, { desc = "Step Into" })
vim.keymap.set("n", "<S-F11>", require("dap").step_out, { desc = "Step Out" })
vim.keymap.set("n", "<S-F5>", require("dap").terminate, { desc = "Stop Debugging" })

-- Debug key mappings using the leader key
vim.keymap.set("n", "<leader>dc", require("dap").continue, { desc = "Debug: Continue/Start" })
vim.keymap.set("n", "<leader>db", require("dap").toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
vim.keymap.set("n", "<leader>dn", require("dap").step_over, { desc = "Debug: Step Over" })
vim.keymap.set("n", "<leader>di", require("dap").step_into, { desc = "Debug: Step Into" })
vim.keymap.set("n", "<leader>do", require("dap").step_out, { desc = "Debug: Step Out" })
vim.keymap.set("n", "<leader>dt", require("dap").terminate, { desc = "Debug: Terminate" })

vim.keymap.set("n", "<leader>dh", function()
    require("dap.ui.widgets").hover()
end, { desc = "Debug: Hover Variable" })

vim.keymap.set("n", "<leader>dr", require("dap").repl.open, { desc = "Debug: Open REPL" })

vim.keymap.set("n", "<leader>du", require("dapui").toggle, { desc = "Debug: Toggle UI" })

-- Show LSP diagnostics popup with leader key combo
vim.keymap.set("n", "<leader>de", vim.diagnostic.open_float, { desc = "Show LSP diagnostics popup" })
