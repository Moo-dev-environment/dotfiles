#!/usr/bin/env bash
# bootstrap.sh — symlink dotfiles into ~/.config and ~/.
# Idempotent: existing real files are backed up to *.backup-<UTC ts>,
# already-correct symlinks are left alone.

set -euo pipefail

if [[ -z "${HOME:-}" ]]; then
  echo "bootstrap: \$HOME is not set" >&2
  exit 1
fi

# Resolve repo root from this script's location, following symlinks.
SCRIPT_PATH="$(readlink -f -- "${BASH_SOURCE[0]}")"
REPO="$(cd -- "$(dirname -- "$SCRIPT_PATH")" && pwd -P)"

case "$(uname -s)" in
  Darwin) OS=macos ;;
  Linux)  OS=linux ;;
  *)      echo "bootstrap: unsupported OS: $(uname -s)" >&2; exit 1 ;;
esac

TS="$(date -u +%Y%m%dT%H%M%SZ)"

c_dim()  { printf '\033[2m%s\033[0m' "$*"; }
c_ok()   { printf '\033[32m%s\033[0m' "$*"; }
c_warn() { printf '\033[33m%s\033[0m' "$*"; }
c_info() { printf '\033[36m%s\033[0m' "$*"; }

link() {
  # link <target-on-disk> <source-in-repo>
  local target="$1" src="$2"
  local target_expanded="${target/#\~/$HOME}"

  if [[ ! -e "$src" ]]; then
    echo "  $(c_warn skip)  $target  ($(c_dim "missing source: $src"))"
    return 0
  fi

  # Refuse to link if the target's parent directory resolves into $REPO —
  # otherwise the "back up existing file then create symlink" path will
  # back up $src (because target_expanded resolves to it) and then symlink
  # $src to itself. Seen 2026-05-09 via a stray ~/.config/ghostty dir-symlink.
  local target_parent
  target_parent="$(readlink -f -- "$(dirname -- "$target_expanded")" 2>/dev/null || true)"
  if [[ -n "$target_parent" && "$target_parent" == "$REPO"* ]]; then
    echo "  $(c_warn FAIL) $target  ($(c_dim "parent resolves into repo: $target_parent"))" >&2
    echo "                 $(c_dim "remove the offending symlink and re-run") " >&2
    exit 1
  fi

  mkdir -p -- "$(dirname -- "$target_expanded")"

  if [[ -L "$target_expanded" ]]; then
    local current
    current="$(readlink -- "$target_expanded")"
    if [[ "$current" == "$src" ]]; then
      echo "  $(c_dim ok)    $target  $(c_dim "→ already linked")"
      return 0
    fi
    rm -- "$target_expanded"
  elif [[ -e "$target_expanded" ]]; then
    local backup="${target_expanded}.backup-${TS}"
    mv -- "$target_expanded" "$backup"
    echo "  $(c_warn back) $target  $(c_dim "→ $backup")"
  fi

  ln -s -- "$src" "$target_expanded"
  echo "  $(c_ok link)  $target  $(c_dim "→ $src")"
}

unlink_path() {
  # remove a stale path if it exists and isn't already gone
  local target="$1"
  local target_expanded="${target/#\~/$HOME}"
  if [[ -L "$target_expanded" || -e "$target_expanded" ]]; then
    local backup="${target_expanded}.backup-${TS}"
    mv -- "$target_expanded" "$backup"
    echo "  $(c_warn back) $target  $(c_dim "(removed; → $backup)")"
  fi
}

echo "$(c_info "bootstrap") $(c_dim "(os=$OS, repo=$REPO)")"
echo

# ── shell ────────────────────────────────────────────────────────────
link "~/.zshrc"    "$REPO/zsh/.zshrc"
link "~/.zprofile" "$REPO/zsh/.zprofile"

# ── git ──────────────────────────────────────────────────────────────
link "~/.gitconfig" "$REPO/git/.gitconfig"
# The old split file lived at ~/.config/git/config; its contents are now
# in ~/.gitconfig, so retire it.
unlink_path "~/.config/git/config"

# ── starship ─────────────────────────────────────────────────────────
link "~/.config/starship.toml" "$REPO/starship/starship.toml"

# ── tmux ─────────────────────────────────────────────────────────────
link "~/.config/tmux/tmux.conf" "$REPO/tmux/tmux.conf"

# ── neovim (whole directory) ─────────────────────────────────────────
link "~/.config/nvim" "$REPO/nvim"

# ── ghostty (single config; per-OS overlays were dropped in favor of
#    inline `?config.local` for machine-local overrides) ──────────────
link "~/.config/ghostty/config" "$REPO/ghostty/config"

# ── alacritty (whole directory — alacritty.toml + themes/) ───────────
link "~/.config/alacritty" "$REPO/alacritty"

# ── bat ──────────────────────────────────────────────────────────────
link "~/.config/bat/config" "$REPO/bat/config"

# ── clangd ───────────────────────────────────────────────────────────
# clangd reads its user config from a different path on macOS — link both so
# the same repo file drives clangd regardless of platform.
link "~/.config/clangd/config.yaml" "$REPO/clangd/config.yaml"
if [[ "$OS" == "macos" ]]; then
  link "~/Library/Preferences/clangd/config.yaml" "$REPO/clangd/config.yaml"
fi

# ── login shell ──────────────────────────────────────────────────────
echo
ZSH_BIN="$(command -v zsh || true)"
if [[ -z "$ZSH_BIN" ]]; then
  echo "$(c_warn login-shell) zsh not found on PATH; skipping chsh"
else
  current_shell="$(getent passwd "$USER" 2>/dev/null | cut -d: -f7 || echo "${SHELL:-}")"
  if [[ "$current_shell" == "$ZSH_BIN" ]]; then
    echo "$(c_dim "login-shell")  $(c_dim "already $ZSH_BIN; skipping chsh")"
  elif ! grep -qx "$ZSH_BIN" /etc/shells 2>/dev/null; then
    echo "$(c_warn login-shell) $ZSH_BIN not listed in /etc/shells; skipping chsh"
    echo "$(c_dim "             ") to enable: sudo sh -c 'echo $ZSH_BIN >> /etc/shells' && chsh -s $ZSH_BIN"
  elif [[ ! -t 0 ]] || [[ "${BOOTSTRAP_NO_CHSH:-}" == 1 ]]; then
    echo "$(c_warn login-shell) skipping chsh (non-interactive). Run manually:"
    echo "$(c_dim "             ") chsh -s $ZSH_BIN"
  else
    echo "$(c_info "login-shell") $(c_dim "running: chsh -s $ZSH_BIN  (will prompt for password)")"
    if chsh -s "$ZSH_BIN"; then
      echo "$(c_ok "login-shell") $(c_dim "now $ZSH_BIN — takes effect on next login")"
    else
      echo "$(c_warn login-shell) chsh failed; run manually: chsh -s $ZSH_BIN"
    fi
  fi
fi

echo
echo "$(c_ok done)"
