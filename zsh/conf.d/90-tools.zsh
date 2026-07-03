# Tool integrations (eval hooks). Deliberately the LAST module: they override
# builtins (cd) and rely on PATH/EDITOR being final.

command -v direnv  &>/dev/null && eval "$(direnv hook zsh)"
command -v mise    &>/dev/null && eval "$(mise activate zsh)"
command -v thefuck &>/dev/null && eval "$(thefuck --alias)"
command -v atuin   &>/dev/null && eval "$(atuin init zsh --disable-up-arrow)"

# try (Omarchy): scratch dirs under ~/Work/tries. Lazy — the first call
# replaces this stub with the real function, so startup pays nothing.
if command -v try &>/dev/null; then
  try() {
    unset -f try
    eval "$(SHELL=$(command -v zsh) command try init ~/Work/tries)"
    try "$@"
  }
fi

# zoxide replaces cd; keep it at the very end — its doctor warns if any hooks
# register after it.
command -v zoxide  &>/dev/null && eval "$(zoxide init zsh --cmd cd)"
