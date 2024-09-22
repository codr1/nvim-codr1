local map = vim.keymap.set

map("n", "<leader>tt", function()
    require("base46").toggle_transparency()
end, { desc = "Toggle Transparency" })

map("n", "<leader>ut", function()
    vim.cmd.UndotreeToggle()
end, { desc = "Toggle UndoTree" })

--vim.keymap.set('n', '<leader>ut', vim.cmd.UndotreeToggle), {desc = "Toggle UndoTree"}
