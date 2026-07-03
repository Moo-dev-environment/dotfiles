# Shell hooks (cross-platform). Runs after 82-macos so the APFS case hook
# fires before the title hook (title should show the canonical PWD).

autoload -Uz add-zsh-hook

_set_terminal_title() {
  [[ -t 1 ]] || return
  local title="${PWD/#$HOME/~}"
  print -Pn "\e]0;${title}\a"
}
add-zsh-hook chpwd _set_terminal_title
_set_terminal_title
