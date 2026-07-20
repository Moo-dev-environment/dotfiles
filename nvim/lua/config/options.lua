-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here.
vim.g.ai_cmp = false
vim.opt.equalalways = false
vim.opt.splitkeep = "screen"
vim.opt.wrap = true
vim.opt.scrolloff = 10
vim.opt.sidescrolloff = 8
-- (LazyVim already sets `relativenumber = true`, so we don't redeclare it.)

-- Jupyter/Molten: use a dedicated venv as Neovim's Python 3 host so `pynvim`
-- and `jupyter_client` are always importable, regardless of the active project
-- venv. Falls back to $PATH lookup on machines without this venv (e.g. Arch).
local nvim_py = vim.fn.expand("~/.venvs/nvim/bin/python")
if vim.fn.executable(nvim_py) == 1 then
  vim.g.python3_host_prog = nvim_py
end
