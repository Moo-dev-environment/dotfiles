-- Smarter <C-a> / <C-x>: increment/decrement numbers, dates, hex, and toggle
-- booleans / logical operators. `g<C-a>` / `g<C-x>` do sequential bumps over a
-- visual selection.
return {
  {
    "monaqa/dial.nvim",
    keys = {
      { "<C-a>", function() return require("dial.map").inc_normal() end, expr = true, mode = "n", desc = "Increment" },
      { "<C-x>", function() return require("dial.map").dec_normal() end, expr = true, mode = "n", desc = "Decrement" },
      { "<C-a>", function() return require("dial.map").inc_visual() end, expr = true, mode = "v", desc = "Increment" },
      { "<C-x>", function() return require("dial.map").dec_visual() end, expr = true, mode = "v", desc = "Decrement" },
      { "g<C-a>", function() return require("dial.map").inc_gvisual() end, expr = true, mode = "v", desc = "Increment (seq)" },
      { "g<C-x>", function() return require("dial.map").dec_gvisual() end, expr = true, mode = "v", desc = "Decrement (seq)" },
    },
    config = function()
      local augend = require("dial.augend")
      require("dial.config").augends:register_group({
        default = {
          augend.integer.alias.decimal_int,
          augend.integer.alias.hex,
          augend.date.alias["%Y-%m-%d"],
          augend.constant.alias.bool, -- true <-> false
          augend.constant.new({ elements = { "&&", "||" }, word = false }),
          augend.constant.new({ elements = { "==", "!=" }, word = false }),
          augend.constant.new({ elements = { "and", "or" } }),
        },
      })
    end,
  },
}
