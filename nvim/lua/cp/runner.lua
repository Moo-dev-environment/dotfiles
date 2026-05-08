-- Lightweight compile-and-run for C / C++ / Java / Python.
--
-- Inside tmux: opens the run in a new pane via `tmux split-window` (right side).
-- Outside tmux: falls back to a Neovim `:terminal` split.
-- If `input.txt` (or `in.txt` / `stdin.txt`) sits next to the source, it's piped on stdin.
local M = {}

local function buf_info()
  local path = vim.api.nvim_buf_get_name(0)
  if path == "" then
    return nil, "Save the buffer first."
  end
  return {
    path = path,
    dir = vim.fn.fnamemodify(path, ":p:h"),
    name = vim.fn.fnamemodify(path, ":t"),
    stem = vim.fn.fnamemodify(path, ":t:r"),
    ext = vim.fn.fnamemodify(path, ":e"),
  }
end

local function shquote(s)
  return vim.fn.shellescape(s)
end

local LANG = {
  c = {
    match = function(b)
      return b.ext == "c"
    end,
    compile = function(b)
      return string.format(
        "cd %s && gcc -O2 -std=gnu17 -Wall -Wextra -o %s %s -lm",
        shquote(b.dir),
        shquote(b.stem),
        shquote(b.name)
      )
    end,
    run = function(b)
      return string.format("./%s", shquote(b.stem))
    end,
  },
  cpp = {
    match = function(b)
      return b.ext == "cpp" or b.ext == "cc" or b.ext == "cxx"
    end,
    compile = function(b)
      local includes = vim.fn.stdpath("config") .. "/include"
      return string.format(
        "cd %s && g++ -O2 -std=gnu++20 -Wall -Wextra -Wshadow -DLOCAL -I%s -o %s %s",
        shquote(b.dir),
        shquote(includes),
        shquote(b.stem),
        shquote(b.name)
      )
    end,
    run = function(b)
      return string.format("./%s", shquote(b.stem))
    end,
  },
  java = {
    match = function(b)
      return b.ext == "java"
    end,
    compile = function(b)
      return string.format("cd %s && javac %s", shquote(b.dir), shquote(b.name))
    end,
    run = function(b)
      return string.format("cd %s && java %s", shquote(b.dir), shquote(b.stem))
    end,
  },
  python = {
    match = function(b)
      return b.ext == "py"
    end,
    compile = function(_)
      return "true"
    end,
    run = function(b)
      return string.format("python3 %s", shquote(b.path))
    end,
  },
}

local function detect(b)
  for _, spec in pairs(LANG) do
    if spec.match(b) then
      return spec
    end
  end
end

local function input_file(dir)
  for _, name in ipairs({ "input.txt", "in.txt", "stdin.txt" }) do
    local p = dir .. "/" .. name
    if vim.fn.filereadable(p) == 1 then
      return p
    end
  end
end

-- Run `cmd` somewhere visible. Tmux pane if we're in tmux, else nvim :terminal.
-- We wrap the command so the user sees the exit code and the pane/terminal
-- doesn't vanish before they can read the output. `read -n1` is bash-only
-- (it's `read -k 1` in zsh), so we explicitly invoke bash for the wrapper.
local function term_exec(cmd)
  local wrapped = cmd
    .. [[; ec=$?; echo; printf '\n[exit %s] press any key to close…' "$ec"; read -n1 -r _]]
  if vim.env.TMUX and vim.env.TMUX ~= "" then
    -- -h = split right, -l 45% = take ~45% of the parent's width
    vim.fn.system({ "tmux", "split-window", "-h", "-l", "45%", "bash", "-lc", wrapped })
    return
  end
  -- :terminal runs through &shell. Force bash so the wrapper's `read -n1`
  -- works regardless of the user's login shell, and so the prompt is shown
  -- before the buffer closes.
  vim.cmd("botright 15split | terminal bash -lc " .. vim.fn.shellescape(wrapped))
  vim.cmd("startinsert")
end

function M.compile()
  local b, err = buf_info()
  if not b then
    return vim.notify(err, vim.log.levels.WARN)
  end
  vim.cmd("write")
  local spec = detect(b)
  if not spec then
    return vim.notify("Unsupported filetype", vim.log.levels.WARN)
  end
  term_exec(spec.compile(b))
end

function M.run()
  local b, err = buf_info()
  if not b then
    return vim.notify(err, vim.log.levels.WARN)
  end
  vim.cmd("write")
  local spec = detect(b)
  if not spec then
    return vim.notify("Unsupported filetype", vim.log.levels.WARN)
  end

  local input = input_file(b.dir)
  local run_cmd = spec.run(b)
  if input then
    run_cmd = run_cmd .. " < " .. shquote(input)
  end

  local full
  if spec.compile(b) == "true" then
    full = string.format("cd %s && %s", shquote(b.dir), run_cmd)
  else
    full = string.format("%s && time %s", spec.compile(b), run_cmd)
  end
  term_exec(full)
end

function M.edit_input()
  local b, err = buf_info()
  if not b then
    return vim.notify(err, vim.log.levels.WARN)
  end
  vim.cmd("edit " .. vim.fn.fnameescape(b.dir .. "/input.txt"))
end

function M.edit_output()
  local b, err = buf_info()
  if not b then
    return vim.notify(err, vim.log.levels.WARN)
  end
  vim.cmd("edit " .. vim.fn.fnameescape(b.dir .. "/expected_output.txt"))
end

function M.diff_output()
  local b, err = buf_info()
  if not b then
    return vim.notify(err, vim.log.levels.WARN)
  end
  vim.cmd("write")
  local spec = detect(b)
  if not spec then
    return vim.notify("Unsupported filetype", vim.log.levels.WARN)
  end
  local input = input_file(b.dir) or "/dev/null"
  local expected = b.dir .. "/expected_output.txt"
  if vim.fn.filereadable(expected) == 0 then
    return vim.notify("No expected_output.txt in " .. b.dir, vim.log.levels.WARN)
  end
  local actual = vim.fn.tempname()
  local full = string.format(
    "%s && %s < %s > %s 2>&1 && diff -u %s %s",
    spec.compile(b),
    spec.run(b),
    shquote(input),
    shquote(actual),
    shquote(expected),
    shquote(actual)
  )
  term_exec(full)
end

return M
