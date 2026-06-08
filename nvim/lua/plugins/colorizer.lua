-- Inline preview of hex / rgb / named colors right in the buffer.
-- Handy when editing themes or anything with color literals.
return {
  {
    "catgoose/nvim-colorizer.lua",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      user_default_options = {
        names = false, -- don't colorize words like "red" / "blue"
        css = true,
        tailwind = true,
      },
    },
    config = function(_, opts)
      require("colorizer").setup(opts)
    end,
  },
}
