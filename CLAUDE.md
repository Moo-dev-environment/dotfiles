# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Personal macOS-first dotfiles (with secondary Arch/Omarchy support) for **zsh, Neovim, tmux, Ghostty, Starship, git, bat**. There is no install script — files are **symlinked into `$HOME` / `$XDG_CONFIG_HOME`**, so editing a file in this repo edits the live config.

Established symlinks on this machine:
```
~/.zshrc                  → zsh/.zshrc
~/.zprofile               → zsh/.zprofile
~/.config/nvim            → nvim/                    (whole directory)
~/.config/tmux/tmux.conf  → tmux/tmux.conf
~/.config/ghostty/config  → ghostty/config
~/.config/starship.toml   → starship/starship.toml
~/.config/bat/config      → bat/config
~/.config/clangd/config.yaml → clangd/config.yaml
~/.config/alacritty       → alacritty/               (whole directory)
~/.gitconfig              → git/.gitconfig
```

There is **no sync/build step**. After editing, reload the relevant tool (e.g. `source ~/.zshrc`, `prefix + ,` in tmux, `super+shift+r` in Ghostty, `:Lazy sync` in nvim).

## Validation commands

Use these to verify a config change before declaring it safe — most validate without disturbing running instances:

| Tool | Command |
|---|---|
| zsh | `zsh -i -c ':'` (full interactive load); timing: `zsh -ixc : 2>&1 \| ts -i '%.s' \| tail -50` |
| tmux | `tmux -L _check -f /Users/mo/GITHUB/dotfiles/tmux/tmux.conf start-server \; kill-server` (uses isolated socket — won't touch your running tmux) |
| Ghostty | `ghostty +validate-config --config-file=/Users/mo/GITHUB/dotfiles/ghostty/config` |
| Starship | `STARSHIP_CONFIG=/Users/mo/GITHUB/dotfiles/starship/starship.toml starship print-config` (parse) / `... starship timings` (perf) |
| Neovim | `nvim --headless "+Lazy! sync" +qa` (plugins) / `nvim --headless "+checkhealth" +qa` |

When inspecting a tool, prefer reading from the repo path (these files) rather than the `~/.config` path — they're the same file via symlink, but the repo path is canonical.

## Architecture per tool

### zsh — single-file config with ordering invariants

`zsh/.zshrc` is one ~900-line file (no plugin manager, no `conf.d/` split). Sections execute top-to-bottom and **order is load-bearing**. Before reordering anything, read `zsh/README.md` § "Ordering invariants" — the constraints there (e.g. fzf shell-integration must load *after* the Tab binding so it captures `_tab_complete_smart` as `fzf_default_completion`; plugins must load autosuggestions → syntax-highlighting → history-substring-search) will silently break the shell if violated.

Notable mechanics:
- `_os` (`macos` / `linux` / `wsl`) is set at the top — every later platform branch keys off it.
- macOS-only `_fix_pwd_case` chpwd hook canonicalizes `$PWD` to on-disk casing (APFS is case-insensitive but case-preserving). Symlinks are intentionally *not* resolved.
- `share_history` is on; `inc_append_history` is intentionally off (they overlap and produce duplicates).
- FZF binds containing pipes/parens **must** be single-quoted in `FZF_DEFAULT_OPTS` — fzf parses that env var like a shell command line.
- Plugins are sourced via `_source_first` which probes Homebrew → Arch → Debian paths.
- `zsh/REFERENCE.md` is a complete cheatsheet of every alias/function/binding.

### Neovim — LazyVim base + thin custom layer

`nvim/init.lua` → `lua/config/lazy.lua` bootstraps `lazy.nvim` with `LazyVim/LazyVim` as the base spec and `{ import = "plugins" }` overlaying `lua/plugins/*.lua`. Don't replace LazyVim — extend it.

The five enabled LazyVim *extras* (committed in `nvim/lazyvim.json`, not toggled via `:LazyExtras`):
- `dap.core` (debugger)
- `editor.neo-tree`
- `lang.clangd` (clangd + codelldb + clang-format)
- `lang.java` (jdtls + java-debug + google-java-format)
- `lang.python` (pyright + ruff + debugpy + black)

Custom modules (the parts to actually edit):
- `lua/cp/runner.lua` — tmux-aware compile-and-run for C/C++/Java/Python (`<leader>r{r,c,i,o,d,D}`). Detects `$TMUX`; in tmux it `tmux split-window -h -l 45%`, otherwise `:terminal` split. Pipes `input.txt` / `in.txt` / `stdin.txt` on stdin if present. Wraps the command in `bash -lc` (not the user's `$SHELL`) because the "press any key" tail uses `read -n1` which is bash-specific.
- `lua/plugins/cpp.lua` — C/C++ tooling: pins Mason tools (`clangd`, `clang-format`, `codelldb`), CP-friendly clang-format style (4-space indent, `IndentCaseLabels: true`, `SortIncludes: false`), and `<leader>rD` which compiles `-O0 -g3 -DLOCAL` with the bundled include path and launches codelldb via DAP. Note: codelldb's launch schema uses `stdinFile`, not `stdio`.
- `lua/plugins/competitest.lua` — CompetiTest with port `27121` (matches Competitive Companion browser extension). Tests sit next to source as `<stem>_input<N>.txt` / `<stem>_output<N>.txt`.
- `lua/plugins/all-themes.lua` — preloads ~20 colorschemes lazily so the Omarchy theme switcher can hot-swap.
- `lua/plugins/omarchy-theme-hotreload.lua` — listens on the `LazyReload` user event, re-resolves the colorscheme from LazyVim opts, re-applies it, and re-sources `after/plugin/transparency.lua`. This is what lets Omarchy's external theme rewrites propagate without restarting nvim.
- `lua/config/autocmds.lua` — `BufNewFile` autocmds insert CP boilerplate from `templates/`. Java template substitutes both `$(JAVA_TASK_CLASS)` and `$(FNOEXT)` so the same file works for plain `:e Foo.java` and CompetiTest-spawned files.
- `include/bits/stdc++.h` — shim for macOS clangd (Apple's libc++ doesn't ship this GCC header). The runner and competitest both pass `-I<stdpath('config')>/include`. To make clangd happy in editor diagnostics, drop the same `-I` line into `~/.config/clangd/config.yaml` (see `nvim/docs/troubleshooting.md`).

The `nvim/docs/` directory is the user-facing manual — `cpp.md`, `competitive-programming.md`, `keymaps.md`, `troubleshooting.md`. Update these when changing the user-visible behavior.

### tmux — prefix `Ctrl+Space`, TPM-managed plugins

`tmux/tmux.conf` self-bootstraps: on first run it clones TPM and installs all declared plugins. Notable:
- Prefix is `Ctrl+Space` (not `Ctrl+B`). This **collides with zsh's default `autosuggest-accept`**, so zsh rebinds that to `^F`. Don't reintroduce a `^Space` binding without that compensation.
- `Ctrl+h/j/k/l` (no prefix) navigates between tmux panes *and* nvim splits via `christoomey/vim-tmux-navigator`. The plugin's `prefix + Ctrl+l` rebind is explicitly cleared (`@vim_navigator_prefix_mapping_clear_screen ''`) so the user's "send C-l + clear scrollback" binding wins.
- `tmux-resurrect` captures pane contents — passwords typed at a prompt end up on disk under `~/.local/share/tmux/resurrect/`. Documented at the top of the resurrect block.
- `set -g @plugin '...'` lines are read by TPM at startup; a fresh checkout needs `prefix + I` once.
- Plugin checkouts (`tmux/plugins/`) are gitignored.

### Ghostty — macOS-native terminal, "defensive locks" pattern

`ghostty/config` holds **only customizations** — settings matching upstream defaults are absent, with two exceptions kept explicit on purpose: the **clipboard block** (`clipboard-read = ask`, etc.) and the **macOS security block** (`macos-auto-secure-input`, `macos-secure-input-indication`). These are pinned even though they currently equal defaults — so a future upstream loosening can't slip through silently. Don't strip them as redundant.

Loads optional `~/.config/ghostty/config.local` for machine-local overrides (the `?` prefix means "no error if missing").

### Starship — two-line prompt, runtimes on right

`starship/starship.toml` uses palette `midnight_horizon` (Tokyo Night–leaning). Layout:
- Line 1: identity → directory → git → `$fill` → `cmd_duration`
- Line 2: shlvl → docker/k8s/terraform/cloud → jobs → status → character
- `right_format`: language runtimes only ($python, $nodejs, $bun, $deno, $golang, $rust, $java, $lua, $ruby, $direnv) — they render only when the project actually uses them.

`directory.truncation_length = 100` + `truncate_to_repo = false` is intentional — `0` would collapse to basename (the *opposite* of "no truncation"). `command_timeout = 1500` is bumped from 500 ms because `git status` on a slow filesystem can blow past the default.

### git, bat

- `git/.gitconfig`: delta as pager (with tokyonight theme), zdiff3 conflict style, line numbers on, side-by-side off. The user's email is the GitHub noreply form.
- `bat/config`: just `--theme="tokyonight_night"`. The theme tmTheme lives at `bat/themes/tokyonight_night.tmTheme` — `bat cache --build` is needed after changing themes.

## Cross-tool conventions

- **Theme**: Tokyo Night Storm in tmux/nvim/starship/bat; Catppuccin Macchiato in Ghostty (intentional contrast — macOS chrome is darker than the inner panes).
- **Font**: CaskaydiaMono Nerd Font Mono everywhere that exposes the choice (Ghostty).
- **Editor**: `EDITOR=nvim` (with vim/vi fallback in `.zshrc`).
- **Pager**: bat for `man`/`less`, delta for `git diff`. `delta` is **never** aliased to `diff(1)` — it's a pager, not a diff replacement.

## Editing conventions

- **Don't add a sync/install script** unless asked. The symlink-and-edit-in-place model is intentional.
- **Don't reformat `.zshrc` into `conf.d/` modules.** That layout was deliberately removed (the gitignore still references `*.bak.*` from that migration). The single-file load with explicit ordering is the design.
- **Lua formatting**: 2-space indent, 120-column (see `nvim/stylua.toml`). Run `stylua nvim/` before committing nvim changes.
- **Don't toggle LazyVim extras via `:LazyExtras`** — it persists locally but doesn't reach this repo. Edit `nvim/lazyvim.json`'s `"extras"` array directly.
- **Backups**: timestamped backups (`*.bak.<unix-ts>`) are gitignored — the audit/refactor workflows leave them behind. Clean up after yourself before committing.

## Reference files worth reading first

- `zsh/README.md` — ordering invariants and design rationale (the *why* behind the .zshrc sequence).
- `zsh/REFERENCE.md` — every alias / function / keybinding.
- `nvim/docs/README.md` — index into the per-topic nvim manuals.
- `tmux/TMUX-GUIDE.md` — long-form walkthrough; `tmux/docs/README.md` is the binding cheatsheet.
- `starship/README.md` — module-by-module explanation of the prompt.
- `alacritty/README.md` — Alacritty config walkthrough + cross-platform notes.
- `dev-tools.md` — inventory of Homebrew/mise-managed tools the configs assume.
