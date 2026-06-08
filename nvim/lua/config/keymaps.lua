-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Compile-and-run for C/C++/Java/Python via tmux pane (or :terminal fallback).
local map = vim.keymap.set
map("n", "<leader>rr", function()
  require("cp.runner").run()
end, { desc = "Compile & run" })
map("n", "<leader>rc", function()
  require("cp.runner").compile()
end, { desc = "Compile only" })
map("n", "<leader>ri", function()
  require("cp.runner").edit_input()
end, { desc = "Edit input.txt" })
map("n", "<leader>ro", function()
  require("cp.runner").edit_output()
end, { desc = "Edit expected_output.txt" })
map("n", "<leader>rd", function()
  require("cp.runner").diff_output()
end, { desc = "Diff output vs expected" })

-- Fast Vertical Resizing
map("n", "<leader>[", ":vertical resize -10<CR>", { desc = "Resize split left (Small)" })
map("n", "<leader>]", ":vertical resize +10<CR>", { desc = "Resize split right (Small)" })
map("n", "<leader>{", ":vertical resize -30<CR>", { desc = "Resize split left (Large)" })
map("n", "<leader>}", ":vertical resize +30<CR>", { desc = "Resize split right (Large)" })
