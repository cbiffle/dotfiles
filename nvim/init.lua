-- Use truecolor even in terminals
vim.opt.termguicolors = true
-- Generally assume 4-space indent shift unless overridden (but leave actual
-- tabs at 8 spaces)
vim.opt.shiftwidth = 4
-- Avoid generating new tabs.
vim.opt.expandtab = true
-- Unless told otherwise, my files are 80 columns wide.
vim.opt.textwidth = 80
-- Use information about the current buffer to update the terminal title.
vim.opt.title = true
-- Right-click extends selection instead of manifesting the world's least useful
-- popup menu
vim.opt.mousemodel = "extend"

-- Things that default to "off" currently that I want to leave off:
-- - smartindent: really annoying

-- Without this, neovim will override textwidth for rust files. This only
-- affects textwidth and shiftwidth as far as I can tell.
vim.g.rust_recommended_style = 0

-- Settings I recall liking when I last used gruvbox, ossified here for all
-- eternity.
vim.g.gruvbox_italic = true
vim.g.gruvbox_contrast_dark = 'hard'

-- Initialize the Lazy package manager, bootstrapping from git if required.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- Load plugins from lua/plugins.lua
require('lazy').setup('plugins')

-- Apply my current preferred color scheme.
vim.cmd('colorscheme catppuccin')
