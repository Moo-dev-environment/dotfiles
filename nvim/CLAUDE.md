# CLAUDE.md — Neovim config (dotfiles source of truth)

Guidance for Claude Code when working in this repo. Read this first, then the
detailed docs in [`docs/`](docs/README.md).

## ⚠️ This repo IS the live Neovim config (symlinked)

`~/.config/nvim` is a **symlink → `~/GITHUB/dotfiles/nvim`** (this directory).
They are the *same files* (same inodes) — editing a file here changes the
running Neovim immediately; there is **no copy/sync step**. Commit and push
from this repo. On a new machine: clone the dotfiles, then
`ln -s ~/GITHUB/dotfiles/nvim ~/.config/nvim`.

## What this is

LazyVim-based Neovim tuned for **competitive programming** (C/C++ primary, also
Java + Python) on Omarchy/Arch with tmux. The owner is a competitive
programmer. The `docs/` folder is comprehensive and accurate — trust it, and
**keep it updated when you change plugins/keymaps**.

## Where things live

| Path | What |
|------|------|
| `lazyvim.json` | enabled LazyVim extras (auto-applied) |
| `lua/config/{lazy,options,keymaps,autocmds}.lua` | bootstrap + user overrides |
| `lua/plugins/*.lua` | one file per added/overridden plugin |
| `lua/cp/runner.lua` | tmux-aware compile/run (`<leader>r*`) |
| `ftplugin/{c,cpp,python}.lua` | 4-space indent overrides |
| `docs/` | full documentation (start at `docs/README.md`) |

Key docs: `docs/tools.md` (how to *use* the editor power tools),
`docs/keymaps.md` (all added keys), `docs/cpp.md` +
`docs/competitive-programming.md` (the CP workflow), `docs/plugins.md`,
`docs/lsp.md`, `docs/debugging.md`, `docs/troubleshooting.md`.

## What's configured (high level)

- **CP suite**: `lua/cp/runner.lua`, `competitest.lua` (CompetiTest, `<leader>t*`,
  Competitive Companion on port 27121), `cpp.lua` (CP clang-format style + Mason
  pins + `<leader>rD` codelldb debug with `input.txt` on stdin).
- **LazyVim extras** (`lazyvim.json`): `dap.core`, `lang.clangd`, `lang.java`,
  `lang.json`, `lang.markdown`, `lang.python`, `editor.neo-tree`,
  `coding.mini-surround`, `editor.harpoon2`.
- **Copilot**: enabled via an `import` of `lazyvim.plugins.extras.ai.copilot` in
  **`lua/config/lazy.lua`** (NOT in `lazyvim.json`), tuned in `copilot_config.lua`
  (inline ghost-text, `<S-Tab>` accept). `vim.g.ai_cmp = false` in `options.lua`.
- **Power tools** (standalone files in `lua/plugins/`): `treesitter-context`,
  `undotree` (`<leader>U`), `dial` (`<C-a>`/`<C-x>`), `diffview` (`<leader>gd*`),
  `colorizer`, `rainbow`, `autosave` (`:ASToggle`), `tmux-navigator`,
  `leetcode` (`:Leet`).
- **Theme**: Omarchy. `lua/plugins/theme.lua` is a **machine-specific symlink** →
  `~/.config/omarchy/current/theme/neovim.lua` and is **gitignored** — never
  commit it. `omarchy-theme-hotreload.lua` re-applies the colorscheme +
  `plugin/after/transparency.lua` when Omarchy rewrites the theme.

## Conventions

- **Lua style: stylua, 2-space indent** (`stylua.toml`). Match the surrounding
  files.
- Add a language/tool → append its extra to `lazyvim.json`'s `"extras"` array,
  then `:Lazy sync` (or restart). A one-off plugin → new file in `lua/plugins/`.
- **Never commit `lua/plugins/theme.lua`** (gitignored; per-machine).
- When you add/change a plugin or keymap, update `docs/`: usage → `tools.md`,
  keys → `keymaps.md`, what-it-is → `plugins.md`.

## Verifying changes

- **Syntax-check Lua** (offline): `nvim --headless +"lua assert(loadfile('FILE'))" +qa`.
- **Install/refresh plugins**: `nvim --headless "+Lazy! sync" "+qa"`.
- **Mason tools** (clangd, codelldb, debugpy, pyright, ruff, jdtls,
  clang-format, …) auto-install on first interactive launch; `:Mason` shows
  status. Headless sync does NOT finish Mason downloads (nvim exits first).
- Toolchain expected on the machine: gcc/g++, python3, a JDK ≥ 21 (so `jdtls`
  works), clang-format, gdb, node (for Copilot), tmux. `codelldb` bundles its
  own lldb via Mason, so system `lldb` is not required.

## Notes

- Neovim ≥ 0.11, leader = `<space>`. Plugins/data live in `~/.local/share/nvim`
  (separate from this config; unaffected by the symlink).
- This is a personal config — prefer small, idiomatic LazyVim-style changes and
  explain anything non-obvious in `docs/`.
