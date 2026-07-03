# dotfiles

Personal dotfiles for **Omarchy** (Arch Linux + Hyprland). Each tool lives in its
own directory here and is **symlinked into place** under `~` / `~/.config`, so
editing a file in this repo edits the live config directly (no copy/sync step).

Every tool directory has a **`README.md` that documents the config line by line**
— what each setting does, how to use the tool, and how to validate changes. Start
there for any tool you want to understand.

## Tools & their docs

| Tool | What it is | Docs | Live → repo link |
|---|---|---|---|
| **Hyprland** | Wayland compositor (the desktop itself) | [`hypr/README.md`](hypr/README.md) | `~/.config/hypr` → `hypr/` |
| **Waybar** | Top status bar | [`waybar/README.md`](waybar/README.md) | `~/.config/waybar` → `waybar/` |
| **tmux** | Terminal multiplexer (panes/sessions) | [`tmux/README.md`](tmux/README.md) | `~/.config/tmux/tmux.conf` → `tmux/tmux.conf` |
| **Neovim** | Editor (LazyVim + CP workflow) | [`nvim/README.md`](nvim/README.md) · [`nvim/docs/`](nvim/docs/README.md) | `~/.config/nvim` → `nvim/` |
| **bash** | Login shell on the Omarchy box | [`bash/README.md`](bash/README.md) | **copy only** — not symlinked |
| **Alacritty** | GPU terminal emulator | [`alacritty/README.md`](alacritty/README.md) | `~/.config/alacritty` → `alacritty/` |
| **Starship** | Shell prompt | [`starship/README.md`](starship/README.md) | `~/.config/starship.toml` → `starship/starship.toml` |
| **Fastfetch** | System-info screenshot tool | [`fastfetch/README.md`](fastfetch/README.md) | `~/.config/fastfetch` → `fastfetch/` |
| **clangd** | C/C++ language server config | [`clangd/README.md`](clangd/README.md) | **not deployed** — `~/.config/clangd/` is absent |
| **zsh** | Interactive shell (primary on macOS) — modular `conf.d/` config | [`zsh/README.md`](zsh/README.md) · [`zsh/REFERENCE.md`](zsh/REFERENCE.md) | `~/.zshrc` → `zsh/.zshrc`, `~/.zprofile` → `zsh/.zprofile` (macOS) |

> **Not everything is symlinked.** **bash** files (`~/.bashrc`, …) are **copied**
> here for reference, not linked — editing `bash/` doesn't change the live shell
> on the Omarchy box. **zsh** is the primary shell on macOS and IS symlinked
> there (it merges the old single-file zsh config with the Omarchy bash gems —
> see `zsh/README.md`). See each tool's README for specifics.
>
> **On the macOS machine** (Ghostty terminal; no Omarchy), the portable configs
> are live-symlinked: **zsh** (`~/.zshrc`, `~/.zprofile`), **tmux**
> (`~/.config/tmux/tmux.conf`), **nvim** (`~/.config/nvim`), **starship**
> (`~/.config/starship.toml`), and **clangd** (both `~/.config/clangd/config.yaml`
> and `~/Library/Preferences/clangd/config.yaml`). **fastfetch** and
> **alacritty** are *not* linked there — their configs shell out to `omarchy-*`
> helpers / theme imports that only exist on the Arch box. Ghostty's config is
> native on macOS and not tracked here.

## How the symlink model works

Most tools are symlinked **whole-directory** (`~/.config/<tool>` → `<tool>/`),
except single-file configs (tmux, starship, clangd) which are symlinked file →
file. Each tool's README has the exact link and a **validate-after-editing**
section. To re-create a link manually:

```sh
# whole-dir tool (e.g. hypr):
mv ~/.config/hypr ~/.config/hypr.backup-$(date -u +%Y%m%dT%H%M%SZ)
ln -s ~/GITHUB/dotfiles/hypr ~/.config/hypr

# single-file tool (e.g. tmux):
ln -sf ~/GITHUB/dotfiles/tmux/tmux.conf ~/.config/tmux/tmux.conf
```

Backups of replaced files/dirs are parked next to the original as
`*.backup-<UTC-timestamp>` and are **not** committed.

## Theme integration

Several tools (Alacritty, Waybar, Hyprland, Neovim, fastfetch) don't hardcode
colours — they **import the active Omarchy theme** from
`~/.config/omarchy/current/theme/…`. Switching themes in Omarchy rewrites those
files and the tools restyle automatically. This is why whole-directory symlinks
matter (relative imports must keep resolving). Each tool's README notes its theme
hook.

## Repo conventions

- **Don't edit Omarchy's defaults** under `~/.local/share/omarchy/` or
  `~/.config/omarchy/` — they're replaced on update. Override in *these* files.
- **Live config is the priority.** This repo tracks what's actually running on the
  machine; if they ever diverge, the live config wins and gets copied back.
- Per-tool READMEs are the source of truth. The older top-level `docs/` notes
  (`ARCHITECTURE.md`, `CONFIGS.md`, …) predate the Omarchy migration and may be
  out of date.

---

> **Note:** there is currently **no `bootstrap.sh`** in this repo — the symlinks
> above were created by hand and are documented per-tool. A clean-checkout
> installer would need to be (re)written to reproduce them automatically.
