-- /home/vess/.config/nvim/lua/codr1/debug.lua
-- Debug configurations for various languages
--
-- ────────────────────────────────────────────────────────────────────────────────
-- QUICK HOW-TO
-- ────────────────────────────────────────────────────────────────────────────────
-- All languages use a single key:
--   <leader>dR  →  “Run debug with arguments” (smart per filetype)
--
-- Filetype-specific behavior:
--   • Python (.py):            <leader>dR
--       - Press <leader>dR and hit <Enter> to run current file.
--       - To pass args: type them and hit <Enter>.
--       - Module mode:   type:  mod pkg.module  [args…]
--       - Attach mode:   type:  attach         (expects debugpy on :5678)
--
--   • Go (dlv), Rust (CodeLLDB), C (CodeLLDB):
--       - <leader>dR prompts for a full command; first token is the program path,
--         remaining tokens are args. We run in “exec” mode (no auto-build).
--
--   • Node.js (.js):
--       - <leader>dR prompts; if you just hit <Enter> we’ll launch the current file
--         with Node (runtimeExecutable = "node"), source maps off by default.
--       - You can also type a full command (first token program, rest args).
--
--   • Bun (.ts):
--       - <leader>dR prompts; default launches current file with Bun
--         (runtimeExecutable = "bun") using Node’s inspector protocol.
--
-- PRE-REQS (install once):
--   - Rust/C:    :Mason → codelldb          (or ensure 'codelldb' in PATH)
--   - Go:        :Mason → delve             (or ensure 'dlv'     in PATH)
--   - Python:    pip install debugpy
--   - Node.js:   :Mason → node-debug2-adapter
--                 (package provides nodeDebug.js used by nvim-dap "node2" adapter)
--   - Bun:       bun is installed (and supports --inspect/inspector protocol)
--
-- Notes:
--   - This config prefers CodeLLDB for C/Rust; swap for lldb/gdb if desired.
--   - The single <leader>dR is kept — no extra F-keys needed.
-- ────────────────────────────────────────────────────────────────────────────────

local dap = require "dap"
local last_cmd = {} -- remembers last prompt per-filetype so you can easily repeat

-- ── Rust via CodeLLDB ──────────────────────────────────────────────────────────
dap.adapters.codelldb = {
    type = "server",
    port = "${port}",
    executable = {
        command = "codelldb", -- from Mason or system PATH
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

-- ── Go via Delve ───────────────────────────────────────────────────────────────
dap.adapters.go = {
    type = "server",
    port = "${port}",
    executable = {
        command = "dlv", -- 'dlv' in PATH
        args = { "dap", "-l", "127.0.0.1:${port}" },
    },
}

dap.configurations.go = {
    {
        name = "Launch Go Program",
        type = "go",
        request = "launch",
        program = "${fileDirname}", -- main package in current dir
        mode = "debug",
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
        args = {},
        dlvToolPath = vim.fn.exepath "dlv",
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
        dlvToolPath = vim.fn.exepath "dlv",
    },
}

-- ── C via CodeLLDB (reuse the same adapter as Rust) ────────────────────────────
dap.configurations.c = {
    {
        name = "Launch C executable",
        type = "codelldb",
        request = "launch",
        program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
        end,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
        args = {},
    },
}

-- ── Python via debugpy ─────────────────────────────────────────────────────────
dap.adapters.python = {
    type = "executable",
    command = "python3",
    args = { "-m", "debugpy.adapter" },
}

local function python_path()
    local venv = os.getenv "VIRTUAL_ENV"
    if venv and #venv > 0 then
        return venv .. "/bin/python"
    end
    local conda = os.getenv "CONDA_PREFIX"
    if conda and #conda > 0 then
        return conda .. "/bin/python"
    end
    return "python3"
end

dap.configurations.python = {
    {
        name = "Python: Launch current file",
        type = "python",
        request = "launch",
        program = "${file}",
        console = "integratedTerminal",
        justMyCode = false,
        pythonPath = python_path,
    },
    {
        name = "Python: Module (pkg style)",
        type = "python",
        request = "launch",
        module = function()
            return vim.fn.input "Module (e.g. pkg.module): "
        end,
        console = "integratedTerminal",
        justMyCode = false,
        pythonPath = python_path,
    },
    {
        name = "Python: Attach to 5678",
        type = "python",
        request = "attach",
        connect = { host = "127.0.0.1", port = 5678 },
        justMyCode = false,
        pythonPath = python_path,
    },
}

-- ── Node.js via node-debug2 (Mason: node-debug2-adapter) ───────────────────────
-- Make sure Mason installed this package; adjust path if your install differs:
local node_dbg = vim.fn.stdpath "data" .. "/mason/packages/node-debug2-adapter/out/src/nodeDebug.js"

dap.adapters.node2 = {
    type = "executable",
    command = "node",
    args = { node_dbg },
}

dap.configurations.javascript = {
    {
        name = "Node: Launch current file",
        type = "node2",
        request = "launch",
        program = "${file}", -- run current JS file
        cwd = "${workspaceFolder}",
        runtimeExecutable = "node",
        sourceMaps = false, -- set true if you have proper maps
        protocol = "inspector",
        console = "integratedTerminal",
    },
    {
        name = "Node: Attach 9229",
        type = "node2",
        request = "attach",
        address = "127.0.0.1",
        port = 9229,
        restart = true,
        protocol = "inspector",
    },
}

-- ── Bun (TypeScript) using Node inspector protocol ─────────────────────────────
-- Bun exposes the Node inspector; we reuse node2 and point runtimeExecutable at 'bun'
dap.configurations.typescript = {
    {
        name = "Bun: Launch current file",
        type = "node2",
        request = "launch",
        program = "${file}", -- run current TS file via Bun
        cwd = "${workspaceFolder}",
        runtimeExecutable = "bun",
        sourceMaps = true, -- Bun generates maps for TS
        protocol = "inspector",
        console = "integratedTerminal",
    },
    {
        name = "Bun: Attach 9229",
        type = "node2",
        request = "attach",
        address = "127.0.0.1",
        port = 9229,
        restart = true,
        protocol = "inspector",
    },
}

-- ────────────────────────────────────────────────────────────────────────────────
-- Single “Run debug with arguments” key for ALL languages
--   - Python: no program prompt; default = run current file, optional args.
--             special commands:
--               "mod <pkg.module> [args]"  → launch module
--               "attach"                    → attach to debugpy :5678
--   - JS/TS:   default = run current file with node/bun; or type a full command.
--   - Go/Rust/C and others: your original behavior (prompt for full command),
--                           first token = program path, rest = args. Runs in “exec”.
-- ────────────────────────────────────────────────────────────────────────────────
local function debug_with_arguments()
    local dap = require "dap"
    local ft = vim.bo.filetype
    local configs = dap.configurations[ft]
    if not configs or vim.tbl_isempty(configs) then
        vim.notify("No DAP configurations for filetype: " .. ft, vim.log.levels.ERROR)
        return
    end

    -- Python: zero-friction defaults + modes
    if ft == "python" then
        local prompt = "python args | 'mod <pkg.module> [args]' | 'attach': "
        local input = vim.fn.input(prompt, last_cmd[ft] or "")
        last_cmd[ft] = input

        if input == "attach" then
            local cfg = vim.deepcopy(configs[3] or {})
            if vim.tbl_isempty(cfg) then
                vim.notify("Python attach config missing", vim.log.levels.ERROR)
                return
            end
            dap.run(cfg)
            return
        end

        local mod_name, mod_rest = input:match "^%s*mod%s+([^%s]+)%s*(.*)$"
        if mod_name then
            local cfg = vim.deepcopy(configs[2] or {})
            if vim.tbl_isempty(cfg) then
                vim.notify("Python module config missing", vim.log.levels.ERROR)
                return
            end
            cfg.module = mod_name
            local args = {}
            for a in vim.gsplit(mod_rest or "", "%s+", { trimempty = true }) do
                table.insert(args, a)
            end
            cfg.args = args
            dap.run(cfg)
            return
        end

        -- default: run current file with optional args
        local cfg = vim.deepcopy(configs[1] or {})
        if vim.tbl_isempty(cfg) then
            vim.notify("Python launch config missing", vim.log.levels.ERROR)
            return
        end
        local args = {}
        for a in vim.gsplit(input or "", "%s+", { trimempty = true }) do
            table.insert(args, a)
        end
        cfg.args = args
        -- DO NOT set cfg.mode="exec" for debugpy
        dap.run(cfg)
        return
    end

    -- JavaScript/TypeScript: sensible default is “run current file”
    if ft == "javascript" or ft == "typescript" then
        local default_hint = (ft == "javascript") and "node (current file)" or "bun (current file)"
        local prompt = string.format("%s args or full command (Enter = %s): ", ft, default_hint)
        local input = vim.fn.input(prompt, last_cmd[ft] or "")
        last_cmd[ft] = input

        -- If user typed a full command, fall back to generic path below
        if input ~= "" and input:match "%S" then
        -- fall through to generic path: interpret first token as program
        else
            local idx = (ft == "javascript") and 1 or 1 -- first config in each list is “launch current file”
            local cfg = vim.deepcopy(configs[idx] or {})
            if vim.tbl_isempty(cfg) then
                vim.notify(ft .. " launch config missing", vim.log.levels.ERROR)
                return
            end
            -- no extra args by default; add if you want to pass some
            cfg.args = {}
            dap.run(cfg)
            return
        end
        -- (if we reach here, user typed a command — let generic path handle it)
    end

    -- Generic path (Go/Rust/C/also JS/TS when user typed a full command):
    local prompt = string.format("%s debug command: ", ft)
    local input = vim.fn.input(prompt, last_cmd[ft] or "")
    if input == "" then
        return
    end
    last_cmd[ft] = input

    local tokens = vim.split(input, "%s+")
    local program = vim.fn.expand(tokens[1])
    local args = (#tokens > 1) and vim.list_slice(tokens, 2, #tokens) or {}

    local base = vim.deepcopy(configs[1])
    base.program = program
    base.args = args

    -- Keep your original “exec” override for compiled targets
    if ft == "go" or ft == "rust" or ft == "c" then
        base.mode = "exec"
    end

    dap.run(base)
end

-- Single keymap for all debuggers
vim.keymap.set("n", "<leader>dR", debug_with_arguments, { silent = true, desc = "Run debug with arguments" })
