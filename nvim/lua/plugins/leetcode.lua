-- Solve LeetCode inside Neovim: browse problems, read the description, run and
-- submit. Entry point is `:Leet` (then `:Leet menu`, `:Leet test`, `:Leet submit`).
-- First use prompts a sign-in (it reads your leetcode session cookie).
-- Uses snacks.nvim as the picker (already part of LazyVim).
return {
  {
    "kawre/leetcode.nvim",
    build = ":TSUpdate html",
    cmd = "Leet",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "folke/snacks.nvim",
    },
    opts = {
      lang = "cpp", -- default language for new solutions
      -- picker auto-detects (you have snacks.nvim; no telescope needed)
    },
  },
}
