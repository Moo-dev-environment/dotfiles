-- vim-tmux-navigator — seamless <C-h/j/k/l> navigation between nvim splits and
-- tmux panes. Paired with the tmux-side plugin declared in tmux/tmux.conf.
-- LazyVim binds these keys to window navigation on VeryLazy; we disable the
-- plugin's auto-mappings and register explicit <Cmd>-form bindings via
-- lazy.nvim's `keys` so they take precedence regardless of load order.
return {
  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
    init = function()
      vim.g.tmux_navigator_no_mappings = 1
    end,
    keys = {
      { "<C-h>", "<Cmd>TmuxNavigateLeft<CR>", desc = "Window/tmux: left", mode = { "n" } },
      { "<C-j>", "<Cmd>TmuxNavigateDown<CR>", desc = "Window/tmux: down", mode = { "n" } },
      { "<C-k>", "<Cmd>TmuxNavigateUp<CR>", desc = "Window/tmux: up", mode = { "n" } },
      { "<C-l>", "<Cmd>TmuxNavigateRight<CR>", desc = "Window/tmux: right", mode = { "n" } },
    },
  },
}
