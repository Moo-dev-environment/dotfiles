-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Insert C++ boilerplate on new file (competitive programming template).
autocmd("BufNewFile", {
  group = augroup("CpTemplates", { clear = true }),
  pattern = { "*.cpp", "*.cc", "*.cxx" },
  command = "silent! 0r " .. vim.fn.stdpath("config") .. "/templates/cp.cpp",
})

-- Insert Java boilerplate with classname substitution on new file.
-- We replace both the CompetiTest-style $(FNOEXT) token and the legacy
-- $(JAVA_TASK_CLASS) token so the same template works whether the file is
-- created by CompetiTest (which expands $(FNOEXT) itself before writing)
-- or via plain `:e Foo.java`.
autocmd("BufNewFile", {
  group = augroup("CpTemplatesJava", { clear = true }),
  pattern = "*.java",
  callback = function(args)
    local tpl = vim.fn.stdpath("config") .. "/templates/Main.java"
    if vim.fn.filereadable(tpl) ~= 1 then
      return
    end
    local lines = vim.fn.readfile(tpl)
    local classname = vim.fn.fnamemodify(args.file, ":t:r")
    for i, line in ipairs(lines) do
      line = string.gsub(line, "%$%(JAVA_TASK_CLASS%)", classname)
      line = string.gsub(line, "%$%(FNOEXT%)", classname)
      lines[i] = line
    end
    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
  end,
})
