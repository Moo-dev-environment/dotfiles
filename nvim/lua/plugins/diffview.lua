-- Full-window git diff & file-history viewer. Complements LazyVim's gitsigns
-- (hunks) and lazygit (<leader>gg) with a proper side-by-side diff / log view.
return {
  {
    "sindrets/diffview.nvim",
    dependencies = "nvim-lua/plenary.nvim",
    cmd = {
      "DiffviewOpen",
      "DiffviewClose",
      "DiffviewToggleFiles",
      "DiffviewFocusFiles",
      "DiffviewFileHistory",
    },
    keys = {
      { "<leader>gdo", "<cmd>DiffviewOpen<cr>", desc = "Diffview open" },
      { "<leader>gdc", "<cmd>DiffviewClose<cr>", desc = "Diffview close" },
      { "<leader>gdh", "<cmd>DiffviewFileHistory %<cr>", desc = "File history (current file)" },
      { "<leader>gdH", "<cmd>DiffviewFileHistory<cr>", desc = "File history (repo)" },
    },
    opts = {},
  },
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>gd", group = "diffview" },
      },
    },
  },
}
