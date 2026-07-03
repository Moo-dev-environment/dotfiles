# Shell options, history, word-boundary behaviour.

setopt auto_cd auto_pushd pushd_ignore_dups pushd_silent cdable_vars
setopt complete_in_word always_to_end list_packed auto_menu
unsetopt menu_complete
setopt extended_glob glob_dots null_glob
setopt extended_history hist_expire_dups_first hist_ignore_all_dups
setopt hist_ignore_space hist_find_no_dups hist_reduce_blanks
setopt hist_save_no_dups hist_verify append_history share_history
setopt interactive_comments no_beep rm_star_wait prompt_subst
setopt long_list_jobs notify no_hup no_check_jobs multios
setopt correct no_correct_all

HISTFILE="$HOME/.zsh_history"
HISTSIZE=200000
SAVEHIST=200000
WORDCHARS="${WORDCHARS//\/}"
WORDCHARS="${WORDCHARS//=/}"
WORDCHARS="${WORDCHARS//:/}"
REPORTTIME=10
