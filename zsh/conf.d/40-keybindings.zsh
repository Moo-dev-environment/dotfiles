# Keybindings: emacs mode, smart Tab, word nav, quoting widgets.
# The `^I` binding here MUST run before the fzf module loads — fzf saves the
# previous Tab binding as fzf_default_completion (that's how `cd **<Tab>`
# triggers the picker while plain Tab still hits the smart widget).

bindkey -e

zle -C complete-local-files complete-word _files
_tab_complete_smart() {
  if [[ -z $BUFFER ]]; then
    zle complete-local-files
  else
    zle expand-or-complete
  fi
}
zle -N _tab_complete_smart
bindkey '^I' _tab_complete_smart   # bound BEFORE fzf so fzf saves it as fzf_default_completion

bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
bindkey '^[f'     forward-word
bindkey '^[b'     backward-word
bindkey '^[[H'    beginning-of-line
bindkey '^[[F'    end-of-line
bindkey '^A'      beginning-of-line
bindkey '^E'      end-of-line
bindkey '^W'      backward-kill-word
bindkey '^[d'     kill-word
bindkey '^[[3~'   delete-char
bindkey '^H'      backward-delete-char
bindkey '^K'      kill-line
bindkey '^Y'      yank
bindkey '^_'      undo
bindkey '^[^_'    redo

autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line
bindkey '^Q' push-line-or-edit

# Free ^Q / ^S from terminal flow control so the bindings above actually reach zle.
[[ -t 0 ]] && stty -ixon 2>/dev/null

autoload -Uz modify-current-argument
# Expression is single-quoted so $ARG is expanded by modify-current-argument at
# eval time (when it's set), not at call time (when it's empty). The (qq) /
# (qqq) flags quote the current argument with single / double quotes.
_single_quote_word() { modify-current-argument '${(qq)ARG}' }
_double_quote_word() { modify-current-argument '${(qqq)ARG}' }
zle -N _single_quote_word
zle -N _double_quote_word
bindkey "^['" _single_quote_word
bindkey '^["' _double_quote_word

autoload -Uz bracketed-paste-magic
zle -N bracketed-paste bracketed-paste-magic

# Called by the plugins module once history-substring-search has loaded
# (its widgets only exist post-source).
_bind_history_search() {
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down
  bindkey '^P'   history-substring-search-up
  bindkey '^N'   history-substring-search-down
}
