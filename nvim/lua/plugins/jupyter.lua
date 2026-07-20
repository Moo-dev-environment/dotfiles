-- Jupyter notebooks in Neovim. Three cooperating plugins:
--   jupytext.nvim  -- open/save .ipynb as editable "# %%" percent-format text
--   molten-nvim    -- send cells to a live Jupyter kernel, capture output
--   image.nvim     -- render plot output inline via Ghostty's kitty graphics
-- Kernel: "Python (datascience)" (~/.venvs/ds). Host: ~/.venvs/nvim (pynvim).
-- Keymaps live under <leader>j; see docs/jupyter.md. Requires the venvs set up
-- by the Jupyter install (jupytext CLI at ~/.venvs/nvim/bin/jupytext).

-- [start, finish] (1-indexed, inclusive) of the "# %%" cell the cursor is in.
-- Percent-format cells begin with a line matching "# %%"; text before the first
-- marker counts as cell 1.
local function cell_bounds()
  local cur = vim.api.nvim_win_get_cursor(0)[1]
  local last = vim.api.nvim_buf_line_count(0)
  local function is_marker(lnum)
    local l = vim.api.nvim_buf_get_lines(0, lnum - 1, lnum, false)[1] or ""
    return l:match("^#%s*%%%%") ~= nil
  end
  local start = 1
  for l = cur, 1, -1 do
    if is_marker(l) then
      start = l
      break
    end
  end
  local finish = last
  for l = cur + 1, last do
    if is_marker(l) then
      finish = l - 1
      break
    end
  end
  return start, finish
end

-- Jump to the next/previous "# %%" marker.
local function goto_cell(dir)
  vim.fn.search("^#%s*%%%%", dir == "prev" and "bW" or "W")
end

-- Evaluate the current cell: select it linewise and hand off to Molten, which
-- reads the '< / '> marks set when visual mode exits (the <Esc> below).
local function run_cell(advance)
  local s, e = cell_bounds()
  vim.cmd(string.format("keepjumps normal! %dGV%dG\27", s, e))
  local ok, err = pcall(vim.cmd, "MoltenEvaluateVisual")
  if not ok then
    vim.notify(tostring(err), vim.log.levels.ERROR, { title = "Molten" })
    return
  end
  if advance then
    vim.api.nvim_win_set_cursor(0, { math.min(e, vim.api.nvim_buf_line_count(0)), 0 })
    goto_cell("next")
  end
end

return {
  -- Transparent .ipynb <-> text conversion. lazy=false so its BufReadCmd is
  -- registered before any notebook is opened.
  {
    "GCBallesteros/jupytext.nvim",
    lazy = false,
    opts = {
      style = "hydrogen", -- # %% percent-format cells
      -- Pin the text extension to "py" (-> `--to py:hydrogen`). The default
      -- "auto" makes jupytext infer the language from `language_info` metadata,
      -- which many notebooks (Colab/nbconvert exports, hand-made) omit -- and
      -- then it errors out on open. Notebooks here are Python. See
      -- docs/jupyter.md "Notebook opens as a wall of JSON".
      output_extension = "py",
      force_ft = nil,
    },
  },

  -- Inline image rendering. Loads for the buffers where notebooks live.
  {
    "3rd/image.nvim",
    ft = { "python", "markdown", "ipynb" },
    opts = {
      backend = "kitty", -- Ghostty speaks the kitty graphics protocol
      processor = "magick_cli", -- use the `magick` binary; no luarock build
      integrations = {
        markdown = { enabled = false },
        neorg = { enabled = false },
        html = { enabled = false },
        css = { enabled = false },
      },
      max_width = 100,
      max_height = 12,
      -- Do not clip Molten's plot output windows.
      max_height_window_percentage = math.huge,
      max_width_window_percentage = math.huge,
      window_overlap_clear_enabled = true,
      window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "snacks_notif", "" },
      tmux_show_only_in_active_window = true,
    },
  },

  -- Cell execution engine (Python remote plugin -> needs UpdateRemotePlugins).
  {
    "benlubas/molten-nvim",
    version = "^1.0.0",
    dependencies = { "3rd/image.nvim" },
    build = ":UpdateRemotePlugins",
    init = function()
      vim.g.molten_image_provider = "image.nvim"
      vim.g.molten_output_win_max_height = 20
      vim.g.molten_auto_open_output = false
      vim.g.molten_wrap_output = true
      vim.g.molten_virt_text_output = true -- text results as inline virtual text
      vim.g.molten_virt_lines_off_by_1 = false
      vim.g.molten_use_border_highlights = true
    end,
    keys = {
      { "<leader>ji", "<cmd>MoltenInit datascience<cr>", desc = "Init kernel (datascience)" },
      { "<leader>jI", "<cmd>MoltenInit<cr>", desc = "Init kernel (choose)" },
      { "<leader>jc", function() run_cell(false) end, desc = "Run cell" },
      { "<leader>jj", function() run_cell(true) end, desc = "Run cell + advance" },
      { "<leader>jl", "<cmd>MoltenEvaluateLine<cr>", desc = "Run line" },
      { "<leader>jv", ":<C-u>MoltenEvaluateVisual<cr>gv", mode = "v", desc = "Run selection" },
      { "<leader>jr", "<cmd>MoltenReevaluateCell<cr>", desc = "Re-run cell" },
      { "<leader>jo", "<cmd>MoltenShowOutput<cr>", desc = "Show output" },
      { "<leader>jO", "<cmd>noautocmd MoltenEnterOutput<cr>", desc = "Enter output window" },
      { "<leader>jh", "<cmd>MoltenHideOutput<cr>", desc = "Hide output" },
      { "<leader>jd", "<cmd>MoltenDelete<cr>", desc = "Delete cell output" },
      { "<leader>je", "<cmd>MoltenExportOutput!<cr>", desc = "Export outputs -> .ipynb" },
      { "<leader>jn", "<cmd>MoltenImportOutput<cr>", desc = "Import outputs from .ipynb" },
      { "<leader>jx", "<cmd>MoltenInterrupt<cr>", desc = "Interrupt kernel" },
      { "<leader>jR", "<cmd>MoltenRestart!<cr>", desc = "Restart kernel" },
      { "]j", function() goto_cell("next") end, desc = "Next cell" },
      { "[j", function() goto_cell("prev") end, desc = "Prev cell" },
    },
  },

  -- Name the which-key group.
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>j", group = "jupyter" },
      },
    },
  },
}
