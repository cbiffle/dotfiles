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

return {
    "mrcjkb/rustaceanvim",
    version = "^4",
    -- Only bother with this on rust files.
    ft = { "rust" },
    opts = {
        server = {
            on_attach = function(_, bufnr)
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

