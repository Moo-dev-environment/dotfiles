# Plugins

This config is **LazyVim base + extras + a few user plugin files**. Most
plugins (telescope, snacks, neo-tree, treesitter, lualine, bufferline,
which-key, gitsigns, conform, mason, lspconfig, cmp, etc.) come from
LazyVim itself. This page only documents what's added or layered on top.

## LazyVim extras (auto-applied via `lazyvim.json`)

| Extra | What it adds |
|-------|--------------|
| `lazyvim.plugins.extras.coding.mini-surround` | Surround edits — `gsa`/`gsd`/`gsr`. See [`tools.md`](tools.md#minisurround--quotes-brackets-tags). |
| `lazyvim.plugins.extras.dap.core` | nvim-dap, nvim-dap-ui, nvim-dap-virtual-text, mason-nvim-dap. |
| `lazyvim.plugins.extras.editor.harpoon2` | Pin/jump files — `<leader>H` / `<leader>h` / `<leader>1`–`5`. See [`tools.md`](tools.md#harpoon--jump-between-your-few-working-files). |
| `lazyvim.plugins.extras.editor.neo-tree` | File explorer (`<leader>e`). |
| `lazyvim.plugins.extras.lang.clangd` | clangd LSP via mason; `codelldb` DAP adapter; `clang-format` formatter. |
| `lazyvim.plugins.extras.lang.java` | jdtls + nvim-jdtls; `java-debug-adapter`, `java-test`, `google-java-format`. |
| `lazyvim.plugins.extras.lang.json` | jsonls + SchemaStore. |
| `lazyvim.plugins.extras.lang.markdown` | marksman LSP, `render-markdown.nvim`, markdownlint. |
| `lazyvim.plugins.extras.lang.python` | pyright + ruff LSPs; `debugpy` DAP; `black` formatter; venv-selector. |

> **Copilot** is enabled differently — via an `import` of
> `lazyvim.plugins.extras.ai.copilot` in [`lua/config/lazy.lua`](../lua/config/lazy.lua)
> (not in `lazyvim.json`), then tuned by `copilot_config.lua` below.

To add another language: append the extra path (e.g.
`lazyvim.plugins.extras.lang.rust`) to the `"extras"` array in
`lazyvim.json`, then `:Lazy sync` (or just restart nvim).

## User plugin files (`lua/plugins/`)

### `competitest.lua`

[xeluxee/competitest.nvim](https://github.com/xeluxee/competitest.nvim) — CP
test-case manager. Receives problems from the
[Competitive Companion](https://github.com/jmerle/competitive-companion)
browser extension on port `27121`. Runs all test cases in parallel,
compares outputs (whitespace-insensitive), shows diffs on mismatch. See
[`competitive-programming.md`](competitive-programming.md).

### `cpp.lua`

C/C++ tooling: pins Mason tools (`clangd`, `clang-format`, `codelldb`),
sets a CP-friendly `clang-format` style (LLVM base, 4-space indent,
`ColumnLimit: 0`, short ifs/loops on one line, `SortIncludes: false`),
and adds `<leader>rD` keymap to compile with `-O0 -g3` and launch
`codelldb`, auto-piping `input.txt` / `in.txt` / `stdin.txt` on stdin.
See [`cpp.md`](cpp.md) for the full C/C++ workflow.

### `jupyter.lua`

Jupyter notebooks in-editor — three cooperating plugins:
[jupytext.nvim](https://github.com/GCBallesteros/jupytext.nvim) (`.ipynb` ⇄
`# %%` text), [molten-nvim](https://github.com/benlubas/molten-nvim) (run cells
on a live kernel), and [image.nvim](https://github.com/3rd/image.nvim) (inline
plots via Ghostty's kitty graphics). Keymaps under `<leader>j`. Depends on two
venvs (`~/.venvs/nvim` host, `~/.venvs/ds` kernel) — see
[`jupyter.md`](jupyter.md) for setup, the `%matplotlib inline` requirement, and
troubleshooting. Molten is a Python remote plugin, so its spec carries
`build = ":UpdateRemotePlugins"`.

### Editor / QoL tools

How to *use* these is in [`tools.md`](tools.md); this is just what each file
adds.

- `treesitter-context.lua` — [nvim-treesitter-context](https://github.com/nvim-treesitter/nvim-treesitter-context):
  sticky function/scope header at the top of the window. Toggle `<leader>uK`.
- `undotree.lua` — [mbbill/undotree](https://github.com/mbbill/undotree):
  visual undo-history tree, `<leader>U`.
- `dial.lua` — [monaqa/dial.nvim](https://github.com/monaqa/dial.nvim):
  smarter `<C-a>`/`<C-x>` (numbers, dates, booleans, operators).
- `diffview.lua` — [sindrets/diffview.nvim](https://github.com/sindrets/diffview.nvim):
  side-by-side git diff & file history under `<leader>gd*`. Also registers the
  `<leader>gd` which-key group.
- `colorizer.lua` — [catgoose/nvim-colorizer.lua](https://github.com/catgoose/nvim-colorizer.lua):
  inline hex/rgb color previews.
- `rainbow.lua` — [HiPhish/rainbow-delimiters.nvim](https://github.com/HiPhish/rainbow-delimiters.nvim):
  color-matched nested brackets.
- `autosave.lua` — [okuuva/auto-save.nvim](https://github.com/okuuva/auto-save.nvim):
  writes the buffer on `InsertLeave`/`TextChanged`. Toggle with `:ASToggle`.
- `tmux-navigator.lua` — [christoomey/vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator):
  `<C-h/j/k/l>` across nvim splits and tmux panes (needs the matching
  `tmux.conf` setup for the tmux side).

### AI

- `copilot_config.lua` — tunes [zbirenbaum/copilot.lua](https://github.com/zbirenbaum/copilot.lua)
  (pulled by the `ai.copilot` import): inline ghost-text suggestions,
  auto-trigger, accept with `<S-Tab>`. Run `:Copilot auth` once to sign in.
  See [`tools.md`](tools.md#copilot--inline-suggestions).

### Competitive programming (online judge)

- `leetcode.lua` — [kawre/leetcode.nvim](https://github.com/kawre/leetcode.nvim):
  browse/solve/submit LeetCode in-editor via `:Leet` (default language C++).
  See [`tools.md`](tools.md#leetcodenvim--leetcode-in-the-editor).

### Theme/UI tweaks

- `all-themes.lua` — installs an extended set of colorschemes for
  picking via `<leader>uC`.
- `omarchy-theme-hotreload.lua` — listens on the `LazyReload` user
  event, re-resolves the colorscheme from LazyVim's merged opts, and
  re-applies it plus `plugin/after/transparency.lua`. This is what lets
  Omarchy's external theme rewrites propagate without restarting nvim.
- `disable-news-alert.lua` — suppresses LazyVim's "news" notification.
- `snacks-animated-scrolling-off.lua` — disables snacks' smooth-scroll
  animation.

## Custom Lua module (`lua/cp/`)

### `runner.lua`

Tmux-aware compile-and-run helper for C / C++ / Java / Python. No plugin
dependency — uses `vim.fn.system` to invoke `tmux split-window` when
inside tmux, or `:terminal` otherwise. Keymaps are mounted in
`lua/config/keymaps.lua`. See [`competitive-programming.md`](competitive-programming.md#custom-runner-luacprunnerlua).

## ftplugin overrides (`ftplugin/`)

- `c.lua`, `cpp.lua`, `python.lua` — 4-space indent, `expandtab`, C/C++
  use `// %s` for `commentstring`.
- LazyVim's `lang.java` extra owns Java's per-buffer setup; we don't
  ship `ftplugin/java.lua`.
