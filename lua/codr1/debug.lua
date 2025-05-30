-- /home/vess/.config/nvim/lua/codr1/debug.lua
-- Debug configurations for various languages

-- Rust debugging configuration using CodeLLDB
local dap = require "dap"
local last_cmd = {} -- <<< initialize your arguments table here

dap.adapters.codelldb = {
    type = "server",
    port = "${port}",
    executable = {
        command = "codelldb", -- Ensure this binary is in your PATH (installed via Mason)
        args = { "--port", "${port}" },
    },
}

-- Go debugging configuration using Delve
dap.adapters.go = {
    type = "server",
    port = "${port}",
    executable = {
        command = "dlv", -- Ensure 'dlv' is in your PATH
        args = { "dap", "-l", "127.0.0.1:${port}" },
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

dap.configurations.go = {
    {
        name = "Launch Go Program",
        type = "go",
        request = "launch",
        program = "${fileDirname}", -- Debugs the main package in the directory of the current file
        mode = "debug",
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
        args = {},
        dlvToolPath = vim.fn.exepath "dlv", -- Optional: specifies the path to dlv
    },
    {
        name = "Attach to Go Process",
        type = "go",
        request = "attach",
        mode = "local",
        processId = function()
            return vim.fn.input "PID to attach to: "
        end,
        cwd = "${workspaceFolder}",
        dlvToolPath = vim.fn.exepath "dlv", -- Optional: specifies the path to dlv
    },
}

----
-- Generic “debug with arguments” wrapper for *any* filetype
--   NOTE: For reasons of one messed up project, we are disabling automatic build.
--         We are doing this by overriding the default mode form "debug" to "exec"
--         YOU are responsible for building your binary after any changes.  Make
--         sure you are using debug flags.  We should reverse this stupidity at
--         some point of time.
local last_args = {} -- store previous args per-ft

local function debug_with_arguments()
    local ft = vim.bo.filetype
    local configs = dap.configurations[ft]
    if not configs or vim.tbl_isempty(configs) then
        vim.notify("No DAP configurations for filetype: " .. ft, vim.log.levels.ERROR)
        return
    end

    -- 1) Prompt (prefilled with last)
    local prompt = string.format("%s debug command: ", ft)
    local input = vim.fn.input(prompt, last_cmd[ft] or "")
    if input == "" then
        return
    end
    last_cmd[ft] = input

    -- 2) Split tokens
    local tokens = vim.split(input, "%s+")

    -- 3) Expand first token as program
    local program = vim.fn.expand(tokens[1])

    -- 4) Rest are args
    local args = #tokens > 1 and vim.list_slice(tokens, 2, #tokens) or {}

    -- 5) Clone & override base config
    local cfg = vim.deepcopy(configs[1])
    cfg.program = program
    cfg.args = args
    --cfg.mode = "debug"

    -- run custom build and skip Delve’s internal build step
    -- TODO - this is bullshit.  take it out when you are done with lcf, or rename it or something.
    -- vim.fn.system "./build.sh"
    cfg.mode = "exec"

    -- 6) Launch
    dap.run(cfg)

    -- prompt, prefilled with last_args[ft] (empty on first run)
    --    local prompt = string.format("%s Enter executable command and arugments: ", ft)
    --    local input = vim.fn.input(prompt, last_args[ft] or "")
    --    last_args[ft] = input
    --
    --    -- split and deep-copy the base config
    --    local args_tbl = vim.split(input, "%s+")
    --    local base = configs[1]
    --    local cfg = vim.deepcopy(base)
    --    cfg.args = args_tbl
    --
    --    -- launch!
    --    dap.run(cfg)
end

-- single keymap for all debuggers: <leader>dR
vim.keymap.set("n", "<leader>dR", debug_with_arguments, { silent = true, desc = "Run debug with arguments" })

-- Future debugging configurations for C, TypeScript, Go, Python, etc. can be added here.
--
--
--
--
--
-- https://github.com/theHamsta/nvim-dap-virtual-text
