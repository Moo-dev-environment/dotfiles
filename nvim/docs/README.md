# Neovim configuration

A [LazyVim](https://www.lazyvim.org/)-based setup. The LazyVim distribution
provides the editor UX (UI, statusline, telescope, neo-tree, cmp, treesitter,
LSP scaffolding, default keymaps, which-key groups). On top of that, this
config layers a competitive-programming workflow, a tmux-aware
compile-and-run module, and a set of editor power tools (surround, harpoon,
dial, undotree, diffview, Copilot, …) documented in [`tools.md`](tools.md).

## Directory layout

```
~/.config/nvim/
├── init.lua                         one-liner that calls config.lazy
├── lazyvim.json                     enabled LazyVim extras (auto-applied)
├── lua/
│   ├── config/
│   │   ├── lazy.lua                 bootstraps lazy.nvim + LazyVim spec
│   │   ├── options.lua              user option overrides
│   │   ├── keymaps.lua              user keymaps (incl. <leader>r* runner)
│   │   └── autocmds.lua             user autocmds (currently none)
│   ├── plugins/                     user plugin specs (added on top of LazyVim)
│   │   ├── competitest.lua          CP test-case manager
│   │   ├── cpp.lua                  C/C++ tooling (Mason pins, conform style, <leader>rD)
│   │   ├── leetcode.lua             LeetCode in-editor (:Leet)
│   │   ├── copilot_config.lua       Copilot inline suggestions
│   │   ├── treesitter-context.lua   sticky scope header
│   │   ├── undotree.lua / dial.lua / diffview.lua / colorizer.lua
│   │   ├── rainbow.lua / autosave.lua / tmux-navigator.lua
│   │   ├── all-themes.lua / theme.lua (symlink to omarchy theme)
│   │   ├── disable-news-alert.lua
│   │   ├── omarchy-theme-hotreload.lua
│   │   └── snacks-animated-scrolling-off.lua
│   └── cp/
│       └── runner.lua               tmux-aware compile/run for C/C++/Java/Python
├── ftplugin/
│   ├── c.lua / cpp.lua / python.lua 4-space indent overrides
├── docs/                            you are here
├── lazy-lock.json
└── stylua.toml
```

## What's enabled (`lazyvim.json`)

```
lazyvim.plugins.extras.coding.mini-surround ← gsa/gsd/gsr surround edits
lazyvim.plugins.extras.dap.core             ← nvim-dap + dap-ui + virtual-text
lazyvim.plugins.extras.editor.harpoon2      ← <leader>H / <leader>h / <leader>1-5
lazyvim.plugins.extras.editor.neo-tree
lazyvim.plugins.extras.lang.clangd          ← C/C++ LSP + codelldb DAP + clang-format
lazyvim.plugins.extras.lang.java            ← jdtls + java-debug + google-java-format
lazyvim.plugins.extras.lang.json            ← jsonls + SchemaStore
lazyvim.plugins.extras.lang.markdown        ← marksman + render-markdown + lint
lazyvim.plugins.extras.lang.python          ← pyright + ruff + debugpy
```

These are committed in `lazyvim.json`. On a new machine, cloning this config
and starting nvim is enough — no `:LazyExtras` toggling needed. **Copilot**
(`ai.copilot`) is the exception: it's enabled via an `import` line in
`lua/config/lazy.lua` rather than `lazyvim.json`.

## First launch

1. Start `nvim`. lazy.nvim bootstraps and installs all plugins (LazyVim core
   + the enabled extras + the user plugins). Takes a minute on first run.
2. Mason auto-installs the LSP servers / debuggers / formatters declared by
   the language extras (clangd, pyright, jdtls, codelldb, debugpy,
   clang-format, black, google-java-format, stylua, etc.). `:Mason` shows
   live progress.
3. Treesitter compiles parsers on demand; `:TSUpdate` forces a refresh.
4. **Java needs a system JDK 21** — `jdtls` exits 1 without one. See
   [`troubleshooting.md`](troubleshooting.md#java-lsp-jdtls-quits-exit-1).

## Topic docs

- [`tools.md`](tools.md) — **how to use** the editor power tools (surround,
  harpoon, dial, undotree, diffview, colorizer, Copilot, leetcode, …) with
  step-by-step examples. Start here if you don't know what a key does.
- [`keymaps.md`](keymaps.md) — only the keymaps this config *adds* (LazyVim
  defaults are linked, not duplicated).
- [`plugins.md`](plugins.md) — what each user plugin file contributes.
- [`lsp.md`](lsp.md) — how LSP works in this config (it's mostly LazyVim).
- [`cpp.md`](cpp.md) — task-oriented C/C++ guide: run, test, debug,
  format. Start here if you just want to know how to run code.
- [`competitive-programming.md`](competitive-programming.md) — competitest +
  custom runner workflow.
- [`debugging.md`](debugging.md) — DAP via the `dap.core` extra.
- [`troubleshooting.md`](troubleshooting.md) — gotchas worth knowing.

## Conventions

- Leader is `<space>` (LazyVim default).
- LazyVim's keymap reference is the source of truth for everything not
  listed in [`keymaps.md`](keymaps.md):
  <https://www.lazyvim.org/keymaps>
- To enable additional language tooling on every machine: add a line to
  `lazyvim.json`'s `"extras"` array (don't toggle via `:LazyExtras` — that
  works but only persists locally if you commit the file).
