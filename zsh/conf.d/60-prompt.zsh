# Prompt: Starship, with a hand-rolled vcs_info fallback.

autoload -Uz colors && colors
if command -v starship &>/dev/null; then
  eval "$(starship init zsh)"
else
  autoload -Uz vcs_info
  zstyle ':vcs_info:git:*' formats '%F{cyan}(%b)%f '
  zstyle ':vcs_info:*' enable git
  precmd() { vcs_info }
  PROMPT='%F{green}%n@%m%f:%F{blue}%~%f ${vcs_info_msg_0_}%(?.%F{green}.%F{red})%(!.#.❯)%f '
  RPROMPT='%(?..%F{red}✘ %?%f)'
fi
