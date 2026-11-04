local M = {}

local dap = require("dap")

local function target_config(path, opts)
    assert(type(path) == "string", "debug target path must be a string")
    opts = opts or {}

    return {
        name = opts.name or vim.fn.fnamemodify(path, ":t"),
        type = "codelldb",
        request = "launch",

        program = vim.fn.fnamemodify(path, ":p"),
        cwd = opts.cwd or vim.fn.getcwd(),
        args = opts.args or {},
        env = opts.env,
        stopOnEntry = opts.stop_on_entry or false,
    }
end

local function add_target(language, path, opts)
    local config = target_config(path, opts)

    dap.configurations[language] = dap.configurations[language] or {}

    table.insert(dap.configurations[language], config)
end

local function set_targets(language, targets)
    assert(type(targets) == "table", "debug targets must be a list")

    dap.configurations[language] = {}

    for _, target in ipairs(targets) do
        if type(target) == "string" then
            add_target(language, target)
        else
            assert(type(target) == "table", "debug target must be a path or target table")
            add_target(language, target.path, target.opts)
        end
    end
end

M.cpp = {
    -- Replaces configurations registered by mason-nvim-dap for C++.
    -- Each target can be a path or { path = "…", opts = { … } }.
    set_targets = function(targets)
        set_targets("cpp", targets)
    end,
    add_target = function(path, opts)
        add_target("cpp", path, opts)
    end,
}

M.rust = {
    -- Replaces configurations registered by mason-nvim-dap for Rust.
    -- Each target can be a path or { path = "…", opts = { … } }.
    set_targets = function(targets)
        set_targets("rust", targets)
    end,
    add_target = function(path, opts)
        add_target("rust", path, opts)
    end,
}

M.python = {
    -- Launches the Python file in the current buffer via mason-nvim-dap's debugpy adapter.
    default_target = {
        name = "Launch current file",
        type = "python",
        request = "launch",
        program = "${file}",
        cwd = vim.fn.getcwd(),
    },
}

dap.configurations.python = dap.configurations.python or {}
table.insert(dap.configurations.python, M.python.default_target)

return M
