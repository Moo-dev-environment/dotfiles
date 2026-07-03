# Environment: locale, editor, XDG dirs, pager, colors, PATH.

export LANG="en_US.UTF-8"
[[ $_os == macos ]] && export LC_ALL="en_US.UTF-8"

if   command -v nvim &>/dev/null; then export EDITOR=nvim VISUAL=nvim
elif command -v vim  &>/dev/null; then export EDITOR=vim  VISUAL=vim
else                                    export EDITOR=vi   VISUAL=vi
fi
export SUDO_EDITOR="$EDITOR"

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

if command -v bat &>/dev/null; then
  export PAGER="bat --paging=always"
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
  export MANROFFOPT="-c"
  # Use the Tokyo Night theme only when it's actually installed AND bat's
  # theme cache has been built — otherwise bat warns "Unknown theme" on every
  # invocation. Fall back to `ansi` (a bat built-in, Omarchy's default).
  if [[ -f "$XDG_CONFIG_HOME/bat/themes/tokyonight_night.tmTheme" \
        && -f "$XDG_CACHE_HOME/bat/themes.bin" ]]; then
    export BAT_THEME="tokyonight_night"
  else
    export BAT_THEME="ansi"
  fi
else
  export PAGER="less -RFX"
  export MANPAGER="less -RFX"
  export LESS="-FRX"
fi

export LESS_TERMCAP_mb=$'\e[1;32m'
export LESS_TERMCAP_md=$'\e[1;32m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;4;31m'

_dir_color='di=33'
if [[ -n ${LS_COLORS:-} ]]; then
  _ls_colors=("${(@s.:.)LS_COLORS}")
  _ls_colors=("${(@)_ls_colors:#di=*}")
else
  _ls_colors=()
fi
_ls_colors+=("$_dir_color")
export LS_COLORS="${(j.:.)_ls_colors}"
if [[ -n ${EZA_COLORS:-} ]]; then
  _eza_colors=("${(@s.:.)EZA_COLORS}")
  _eza_colors=("${(@)_eza_colors:#di=*}")
else
  _eza_colors=()
fi
_eza_colors+=("$_dir_color")
export EZA_COLORS="${(j.:.)_eza_colors}"
export LSCOLORS="dxfxcxdxbxegedabagacad"
unset _dir_color _ls_colors _eza_colors

typeset -U path PATH
path=("$HOME/bin" "$HOME/.local/bin" $path)
if [[ $_os == macos && -d /opt/homebrew ]]; then
  path=(/opt/homebrew/bin /opt/homebrew/sbin $path)
  export MANPATH="/opt/homebrew/share/man:$MANPATH"
fi
export PATH

# Toolchain env shim (rustup / uv / mise). Also sourced in .zprofile, but on
# Linux terminal emulators start non-login shells that skip .zprofile.
[[ -f "$HOME/.local/bin/env" ]] && source "$HOME/.local/bin/env"
