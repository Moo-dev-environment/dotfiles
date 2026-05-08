# Plugins

This config is **LazyVim base + extras + a few user plugin files**. Most
plugins (telescope, snacks, neo-tree, treesitter, lualine, bufferline,
which-key, gitsigns, conform, mason, lspconfig, cmp, etc.) come from
LazyVim itself. This page only documents what's added or layered on top.

## LazyVim extras (auto-applied via `lazyvim.json`)

| Extra | What it adds |
|-------|--------------|
| `lazyvim.plugins.extras.dap.core` | nvim-dap, nvim-dap-ui, nvim-dap-virtual-text, mason-nvim-dap. |
| `lazyvim.plugins.extras.editor.neo-tree` | File explorer (`<leader>e`). |
| `lazyvim.plugins.extras.lang.clangd` | clangd LSP via mason; `codelldb` DAP adapter; `clang-format` formatter. |
| `lazyvim.plugins.extras.lang.java` | jdtls + nvim-jdtls; `java-debug-adapter`, `java-test`, `google-java-format`. |
| `lazyvim.plugins.extras.lang.python` | pyright + ruff LSPs; `debugpy` DAP; `black` formatter; venv-selector. |

To add another language: append the extra path (e.g.
`lazyvim.plugins.extras.lang.rust`) to the `"extras"` array in
`lazyvim.json`, then `:Lazy sync` (or just restart nvim).

## User plugin files (`lua/plugins/`)

### `competitest.lua`

[xeluxee/competitest.nvim](https://github.com/xeluxee/competitest.nvim) — CP
test-case manager. Receives problems from the
[Competitive Companion](https://github.com/jmerle/competitive-companion)
browser extension on port `27121`. Runs all test cases in parallel,
compares outputs (whitespace-insensitive), shows diffs on mismatch. Tied
into the templates under `~/.config/nvim/templates/` and the C++ shim
under `~/.config/nvim/include/`. See
[`competitive-programming.md`](competitive-programming.md).

### `cpp.lua`

C/C++ tooling: pins Mason tools (`clangd`, `clang-format`, `codelldb`),
sets a CP-friendly `clang-format` style (LLVM base, 4-space indent,
`ColumnLimit: 0`, short ifs/loops on one line, `SortIncludes: false`),
and adds `<leader>rD` keymap to compile with `-O0 -g3` and launch
`codelldb`, auto-piping `input.txt` / `in.txt` / `stdin.txt` on stdin.
See [`cpp.md`](cpp.md) for the full C/C++ workflow.

### Theme/UI tweaks

- `all-themes.lua` — installs an extended set of colorschemes for
  picking via `<leader>uC`.
- `omarchy-theme-hotreload.lua` — listens on the `LazyReload` user
  event, re-resolves the colorscheme from LazyVim's merged opts, and
  re-applies it plus `after/plugin/transparency.lua`. This is what lets
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
