# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Personal **Omarchy** (Arch Linux + Hyprland) dotfiles for **Hyprland, Waybar,
tmux, Neovim, Alacritty, Starship, fastfetch, clangd** (plus dormant **zsh** and
reference-only **bash** configs). Each tool lives in its own top-level directory
and is **symlinked into `$HOME` / `$XDG_CONFIG_HOME`**, so editing a file in this
repo edits the live config directly — no copy/sync step.

**The guiding principle: the live config is the source of truth.** The repo
tracks what is actually running on the machine. When they diverge, the live
config wins and gets copied back into the repo.

### Symlink reality (verified)

| Live path | Repo source | State |
|---|---|---|
| `~/.config/nvim` | `nvim/` | symlink (whole dir) |
| `~/.config/hypr` | `hypr/` | symlink (whole dir) |
| `~/.config/waybar` | `waybar/` | symlink (whole dir) |
| `~/.config/alacritty` | `alacritty/` | symlink (whole dir) |
| `~/.config/fastfetch` | `fastfetch/` | symlink (whole dir) |
| `~/.config/tmux/tmux.conf` | `tmux/tmux.conf` | symlink (single file) |
| `~/.config/starship.toml` | `starship/starship.toml` | symlink (single file) |
| `~/.bashrc`, `~/.bash_profile`, `~/.profile`, `~/.bash_logout` | `bash/` | **copy only — NOT symlinked** |
| `~/.zshrc`, `~/.zprofile` | `zsh/` | **not symlinked; zsh is dormant** (login shell is **bash**) |
| `~/.config/clangd/config.yaml` | `clangd/config.yaml` | **not deployed** (`~/.config/clangd/` is absent) |

Things to know:
- **bash is the login shell**, and its files are copied here for reference, not
  symlinked — editing `bash/` does not change the live shell. See `bash/README.md`.
- **zsh is legacy/dormant** — the config still lives in `zsh/` but isn't linked or
  active. Don't assume edits there affect anything live.
- **clangd's repo config isn't currently linked** into `~/.config/clangd/`. If you
  need editor-wide clangd flags applied, the symlink has to be created; today
  nvim's own `cpp.lua` is what passes compile flags. See `clangd/README.md`.
- There is currently **no `bootstrap.sh`** — the symlinks were created by hand.
  A clean-checkout installer would need to be (re)written. Don't invent one
  unless asked.

### Re-creating a symlink by hand

```sh
# whole-dir tool (back up the original first):
mv ~/.config/hypr ~/.config/hypr.backup-$(date -u +%Y%m%dT%H%M%SZ)
ln -s ~/GITHUB/dotfiles/hypr ~/.config/hypr
# single-file tool:
ln -sf ~/GITHUB/dotfiles/tmux/tmux.conf ~/.config/tmux/tmux.conf
```

Backups of replaced files/dirs are parked next to the original as
`*.backup-<UTC-timestamp>` and are gitignored — clean them up before committing.

## Per-tool docs are the source of truth

Every tool directory has a **`README.md` documenting its config line by line**,
how to use the tool, and a *validate-after-editing* section. **When you change a
config, update that tool's README.** Index: top-level `README.md`.

- `hypr/README.md` · `waybar/README.md` · `tmux/README.md` · `starship/README.md`
- `alacritty/README.md` · `fastfetch/README.md` · `clangd/README.md` · `bash/README.md`
- `nvim/README.md` + `nvim/docs/` (and `nvim/CLAUDE.md` for nvim-specific guidance)
- `zsh/README.md` + `zsh/REFERENCE.md`

> The older top-level `docs/` (`ARCHITECTURE.md`, `CONFIGS.md`, `CUSTOMIZATION.md`,
> `SETUP.md`, `TROUBLESHOOTING.md`) predate the Omarchy migration and are **stale**
> — they describe a macOS-first cross-platform repo with `bootstrap.sh`,
> `ghostty/`, `git/`, `bat/` and zsh `conf.d/` modules that no longer exist. Don't
> trust them; prefer the per-tool READMEs.

## Validation commands

Validate a change before declaring it safe (most don't disturb running instances):

| Tool | Command |
|---|---|
| Hyprland | `Hyprland --verify-config` (prints `config ok`); apply with `hyprctl reload` |
| Waybar | `timeout 3 waybar -c ~/.config/waybar/config.jsonc -s ~/.config/waybar/style.css` (errors → stderr) |
| tmux | `tmux -L _check -f ~/.config/tmux/tmux.conf start-server \; kill-server` (isolated socket) |
| Alacritty | `alacritty migrate --dry-run -c ~/.config/alacritty/alacritty.toml`; live-reloads on save |
| Starship | `STARSHIP_CONFIG=~/.config/starship.toml starship print-config` (parse) / `starship timings` (perf) |
| fastfetch | `fastfetch -c ~/.config/fastfetch/config.jsonc --logo none >/dev/null && echo OK` |
| Neovim | `nvim --headless "+Lazy! sync" +qa` (plugins) / `nvim --headless "+checkhealth" +qa` |
| bash | `bash -n ~/.bashrc && echo OK` (syntax) / `bash -ic ':'` (interactive load) |

When inspecting a tool, read from the repo path (these files), not `~/.config/…` —
same file via symlink, but the repo path is canonical.

## Omarchy theme integration

Alacritty, Waybar, Hyprland, Neovim and fastfetch don't hardcode colours — they
**import the active Omarchy theme** from `~/.config/omarchy/current/theme/…`.
Switching themes in Omarchy rewrites those files and the tools restyle
automatically. This is why several tools are symlinked **whole-directory**: a
relative `@import` (e.g. `waybar/style.css`) must keep resolving through the link.

**Never edit Omarchy's managed files** under `~/.local/share/omarchy/` or
`~/.config/omarchy/` — they're overwritten on Omarchy update. Override them in
*these* repo files (which are sourced/imported after the defaults).

## Architecture per tool

### Hyprland (`hypr/`) — the compositor, Omarchy-layered

`hyprland.conf` is the entry point: it `source`s Omarchy's defaults from
`~/.local/share/omarchy/default/hypr/…` first, then the current theme, then *your*
override files (`monitors`, `input`, `bindings`, `looknfeel`, `autostart`), then
runtime toggles from `~/.local/state/omarchy/toggles/hypr/*.conf`. Order is
load-bearing — your files win because they're sourced last. All `source` lines use
absolute paths, so the whole-dir symlink resolves cleanly. The standard
window/tiling/media/screenshot keybindings come from the Omarchy defaults;
`bindings.conf` here only adds **app-launch** shortcuts. Companion daemons
(`hypridle`, `hyprlock`, `hyprsunset`, `xdg-desktop-portal-hyprland`) read their
config from this dir too. Full detail: `hypr/README.md`.

### Waybar (`waybar/`) — status bar

`config.jsonc` (modules + behaviour) and `style.css` (GTK CSS). `style.css` opens
with a **relative** `@import "../omarchy/current/theme/waybar.css"` that resolves
lexically through the symlink to the active theme — this is why `waybar/` is a
whole-dir symlink. Custom modules shell out to `omarchy-*` helper scripts.
`config.jsonc` is JSON-with-comments; CSS hot-reloads, structural changes need a
bar restart. Detail: `waybar/README.md`.

### tmux (`tmux/`) — minimal, plugin-free

`tmux/tmux.conf` is a ~100-line Omarchy config: prefix `Ctrl+Space` (with `Ctrl+b`
as `prefix2`), reload on `prefix + q`, splits `|`/`-`/`\`, prefix-free pane nav
(`Ctrl+Alt+arrows`) and window/session switching (`Alt+…`, `P`/`N`). Theme uses
**named** colours (`blue`, `brightblack`, `default`) not hex, so it re-themes with
the terminal palette. **No plugins** — deliberately, so a fresh checkout works
with zero install. (This replaced an older 548-line plugin-heavy config; don't
reintroduce TPM/plugins.) Detail: `tmux/README.md`.

### Neovim (`nvim/`) — LazyVim + thin custom layer

`~/.config/nvim` is a whole-dir symlink. LazyVim base + `lua/plugins/*.lua`
overlay, tuned for competitive programming (C/C++ primary, Java, Python). It has
its own **`nvim/CLAUDE.md`** (read it before editing nvim) and a comprehensive
**`nvim/docs/`** manual. Theme is Omarchy-driven via a gitignored
`lua/plugins/theme.lua` symlink + `omarchy-theme-hotreload.lua`. Lua style: stylua,
2-space indent (`nvim/stylua.toml`). Don't replace LazyVim — extend it.

### Alacritty (`alacritty/`) — secondary terminal

`alacritty.toml` imports the Omarchy theme (`general.import`), sets the Nerd Font,
OSC-52 clipboard, `Shift/Ctrl+Insert` copy-paste and a `Shift+Return` → `\r`
escape. Live-reloads on save. Detail: `alacritty/README.md`.

### Starship (`starship/`) — prompt

Deliberately minimal: `directory` + `git_branch` + `git_status` + `character`
only. `command_timeout = 200` for snappiness; git-status compressed to Nerd Font
glyphs. Detail: `starship/README.md`.

### fastfetch (`fastfetch/`) — system info

`config.jsonc`: Arch logo + three box-drawn panels (Hardware / Software /
Age·Uptime·Update). Mixes built-in probes with `command` modules calling
`omarchy-*` helpers; the "OS age" line derives install date from `stat -c %W /`.
Detail: `fastfetch/README.md`.

### clangd (`clangd/`) — C/C++ LSP config

`config.yaml` adds `-std=gnu++20 -Wall -Wextra` for loose single-file C/C++ (no
`compile_commands.json`). On Arch, GCC ships `<bits/stdc++.h>` natively, so **no
`-I` is needed** (unlike macOS, which needed a shim). **Don't add `Compiler:
g++-…`** — it breaks member-completion against the libc++ shim on the macOS side.
Note this config is **not currently symlinked** into `~/.config/clangd/`. Detail:
`clangd/README.md`.

### bash (`bash/`) — login shell, reference copies

`~/.bashrc` etc. are **copied** here, not symlinked. The substance lives in
Omarchy's `~/.local/share/omarchy/default/bash/rc`, which `.bashrc` sources;
personal config goes after that line in the *live* file. Detail: `bash/README.md`.

### zsh (`zsh/`) — dormant

Single-file `~900-line .zshrc` with **load-bearing ordering invariants** (read
`zsh/README.md` § "Ordering invariants" before reordering anything). Currently
**not the active shell** (bash is) and **not symlinked**. `zsh/REFERENCE.md` is a
full alias/function/binding cheatsheet. Treat as legacy unless reactivated.

## Editing conventions

- **Live config is priority.** If repo and live diverge, copy live → repo.
- **Don't edit Omarchy's managed files** (`~/.local/share/omarchy/`,
  `~/.config/omarchy/`) — override in these repo files instead.
- **Update the per-tool `README.md`** whenever you change that tool's config.
- **Don't add a `bootstrap.sh`/installer** unless asked — the symlink model is
  manual and intentional for now.
- **Lua**: stylua, 2-space indent, 120-col (`nvim/stylua.toml`). Run `stylua nvim/`
  before committing nvim changes. Follow `nvim/CLAUDE.md` for nvim work.
- **tmux**: keep it plugin-free; don't reintroduce TPM.
- **Backups**: `*.backup-<UTC-ts>` / `*.bak.*` are gitignored — clean up before
  committing.

## Reference files worth reading first

- Top-level `README.md` — index of every tool + its doc.
- Each tool's `README.md` — line-by-line config explanation + validation.
- `nvim/CLAUDE.md` and `nvim/docs/README.md` — the nvim manual.
- `zsh/README.md` — zsh ordering invariants (if you touch the dormant zsh config).
