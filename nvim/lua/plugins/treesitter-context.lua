-- Sticky context: pins the current function / loop / scope to the top of the
-- window while you scroll. Great for reading longer solutions.
return {
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      max_lines = 3, -- how many lines of context, max
      multiline_threshold = 1, -- collapse multiline contexts to 1 line
      separator = "─",
    },
    config = function(_, opts)
      require("treesitter-context").setup(opts)
    end,
    keys = {
      {
        "<leader>uK",
        function()
          require("treesitter-context").toggle()
        end,
        desc = "Toggle Treesitter Context",
      },
    },
  },
}
