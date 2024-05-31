-- rustaceanvim sets up a bunch of Rust stuff, _including_ the
-- rust-analyzer LSP config. This means you DO NOT want to also
-- ask nvim-lspconfig to set up rust-analyzer.

-- rust-analyzer language server configuration
local rust_analyzer_settings = {
    cargo = {
        -- Force all features on to try and ensure that we
        -- build all the code.
        allFeatures = true,
        -- Can't find this in the rust-analyzer docs, but it
        -- seems to help with proc-macros?
        loadOutDirsFromCheck = true,
        -- Allow code we're editing to run arbitrary code on
        -- our computer
        runBuildScripts = true,
    },
    -- Add clippy lints for Rust.
    checkOnSave = {
        allFeatures = true,
        command = "clippy",
        extraArgs = { "--no-deps" },
    },
    procMacro = {
        enable = true,
        ignored = {
            -- I inherited this list of ignored macros, need
            -- to revisit.
            ["async-trait"] = { "async_trait" },
            ["napi-derive"] = { "napi" },
            ["async-recursion"] = { "async_recursion" },
        },
    },
}

local cache = {}
local clients = {}
local non_hubris_bufnrs = {}

local cache_hubris_if_needed = function(client, bufnr)
    -- Have we already cached this hubris info?
    local cached = cache[bufnr]
    if cached ~= nil then
        return cached
    end

    -- Have we already checked this bufnr and decided it's not hubris?
    if non_hubris_bufnrs[bufnr] ~= nil then
        return nil
    end

    -- Might this be a hubris project?
    local dir = client.config.root_dir
    if not string.find(dir, "hubris") then
        non_hubris_bufnrs[bufnr] = true
        return nil
    end

    -- Run `xtask lsp` for the target file, which gives us a JSON
    -- dictionary with bonus configuration.
    local prev_cwd = vim.fn.getcwd()
    vim.cmd("cd " .. dir)
    local cmd = dir .. "/target/debug/xtask lsp "
    -- Notify `xtask lsp` of existing clients in the CLI invocation,
    -- so it can check against them first (which would mean a faster
    -- attach)
    for _,v in pairs(clients) do
        local c = vim.fn.escape(vim.json.encode(v), '"')
        cmd = cmd .. '-c"' .. c .. '" '
    end
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    local handle = io.popen(cmd .. bufname)
    handle:flush()
    local result = handle:read("*a")
    handle:close()
    vim.cmd("cd " .. prev_cwd)

    -- If `xtask` doesn't know about `lsp`, then it will print an error to
    -- stderr and return nothing on stdout.
    if result == "" then
        vim.notify("recompile `xtask` for `lsp` support", vim.log.levels.WARN)
    end

    -- If the given file should be handled with special care, then
    -- we give the rust-analyzer client a custom name (to prevent
    -- multiple buffers from attaching to it), then cache the JSON in
    -- a local variable for use in `on_attach`
    local json = vim.json.decode(result)
    if json["Ok"] ~= nil then
        -- Do rust-analyzer builds in a separate folder to avoid blocking
        -- the main build with a file lock.
        table.insert(json.Ok.buildOverrideCommand, "--target-dir")
        table.insert(json.Ok.buildOverrideCommand, "target/rust-analyzer")
        local cache_entry = {
            name = "rust_analyzer_" .. json.Ok.hash,
            json = json,
        }
        cache[bufnr] = cache_entry
        table.insert(clients, { toml = json.Ok.app, task = json.Ok.task })
        return cache_entry
    else
        non_hubris_bufnrs[bufnr] = true
        return nil
    end
end

local apply_hubris_config = function(client, json)
    local config = vim.deepcopy(client.config)
    local ra = config.settings["rust-analyzer"]
    ra.cargo = {
        extraEnv = json.Ok.extraEnv,
        features = json.Ok.features,
        noDefaultFeatures = true,
        target = json.Ok.target,
        buildScripts = {
            overrideCommand = json.Ok.buildOverrideCommand,
        },
    }
    ra.checkOnSave = {}
    ra.check = {
        overrideCommand = json.Ok.buildOverrideCommand,
    }
    config.lspinfo = function()
        return {
            "Hubris app:      " .. json.Ok.app,
            "Hubris task:     " .. json.Ok.task,
        }
    end
    client.config = config
end


return {
    "mrcjkb/rustaceanvim",
    version = "^4",
    -- Only bother with this on rust files.
    ft = { "rust" },
    opts = {
        server = {
            on_attach = function(client, bufnr)
                local cached = cache_hubris_if_needed(client, bufnr)
                if cached ~= nil then
                    apply_hubris_config(client, cached.json)
                end

                -- TODO: I'm not actually sure why these are here.
                vim.keymap.set("n", "<leader>cR", function()
                    vim.cmd.RustLsp("codeAction")
                end, { desc = "Code Action", buffer = bufnr })
                vim.keymap.set("n", "<leader>dr", function()
                    vim.cmd.RustLsp("debuggables")
                end, { desc = "Rust Debuggables", buffer = bufnr })
            end,
            default_settings = {
                ["rust-analyzer"] = rust_analyzer_settings,
            },
        },
    },
    config = function(_, opts)
        -- Force the sign column at left ON for files using
        -- rust-analyzer, to keep from jumping back and forth.
        vim.o.signcolumn = 'yes'

        vim.g.rustaceanvim = vim.tbl_deep_extend("keep", vim.g.rustaceanvim or {}, opts or {})
    end,
}

