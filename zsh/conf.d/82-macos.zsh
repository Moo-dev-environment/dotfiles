# macOS only.
[[ $_os == macos ]] || return 0

alias localip='ipconfig getifaddr en0'
alias flushdns='sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder && echo "DNS flushed"'
alias brewup='brew update && brew upgrade && brew cleanup && echo "Homebrew updated"'
alias brewdump='brew bundle dump --force --file=~/GITHUB/dotfiles/Brewfile && echo "Brewfile updated"'
alias show='open .'
alias hide='chflags hidden'
alias unhide='chflags nohidden'

hidden() {
  local state
  state=$(defaults read com.apple.finder AppleShowAllFiles 2>/dev/null)
  if [[ "$state" == "YES" || "$state" == "true" || "$state" == "1" ]]; then
    defaults write com.apple.finder AppleShowAllFiles NO
    echo "Hidden files: OFF"
  else
    defaults write com.apple.finder AppleShowAllFiles YES
    echo "Hidden files: ON"
  fi
  killall Finder
}
ql()     { qlmanage -p "$@" &>/dev/null & }
notify() { osascript -e "display notification \"$*\" with title \"Terminal\"" }

# APFS is case-insensitive but case-preserving — `cd github` succeeds when the
# folder is GITHUB and PWD reflects what you typed. This hook rewrites PWD to
# the on-disk casing after every cd. Symlinks are left intact.
# Registered BEFORE the terminal-title hook (88) so the title sees the
# canonical PWD.
_canonical_case_into_REPLY() {
  local path="$PWD"
  [[ "$path" != /* ]] && { REPLY="$path"; return; }
  setopt local_options extended_glob no_nomatch
  local result="" part parent matches
  for part in ${(s./.)path}; do
    [[ -z "$part" ]] && continue
    parent="${result:-/}"
    matches=( ${parent}/(#i)${(b)part}(ND[1]) )
    if (( ${#matches} > 0 )); then
      result="${matches[1]}"
    else
      result="${parent%/}/${part}"
      break
    fi
  done
  REPLY="$result"
}

_fix_pwd_case() {
  [[ -n "$_fixing_pwd_case" ]] && return
  local REPLY
  _canonical_case_into_REPLY
  if [[ -n "$REPLY" && "$REPLY" != "$PWD" ]]; then
    typeset -g _fixing_pwd_case=1
    builtin cd -q -- "$REPLY"
    unset _fixing_pwd_case
  fi
}

autoload -Uz add-zsh-hook
add-zsh-hook chpwd _fix_pwd_case
_fix_pwd_case
