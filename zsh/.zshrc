# ~/.zshrc — thin loader; the real config lives in conf.d/*.zsh modules.
# See README.md for layout/ordering invariants, REFERENCE.md for the cheatsheet.

# Resolve this file's real directory (through symlinks) so ~/.zshrc can be a
# symlink into the dotfiles repo and the modules still resolve.
ZSH_CONFIG_DIR="${${(%):-%N}:A:h}"
[[ -d "$ZSH_CONFIG_DIR/conf.d" ]] || ZSH_CONFIG_DIR="$HOME/GITHUB/dotfiles/zsh"
export ZSH_CONFIG_DIR

for _mod in "$ZSH_CONFIG_DIR"/conf.d/[0-9]*.zsh(N); do
  source "$_mod"
done
unset _mod

# Machine-local overrides — not tracked in the repo.
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
