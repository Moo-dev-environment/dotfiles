# See zsh/README.md for layout/install, zsh/REFERENCE.md for the cheatsheet.

case "$OSTYPE" in
  darwin*)  _os=macos ;;
  linux*)
    if [[ -n "$WSL_DISTRO_NAME" || -f /proc/sys/fs/binfmt_misc/WSLInterop ]]; then
      _os=wsl
    else
      _os=linux
    fi
    ;;
  *)        _os=other ;;
esac
export _os

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
  export BAT_THEME="tokyonight_night"
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

if [[ $_os == macos && -d /opt/homebrew/share/zsh/site-functions ]]; then
  fpath=(/opt/homebrew/share/zsh/site-functions $fpath)
elif [[ $_os == linux && -d /usr/share/zsh/site-functions ]]; then
  fpath=(/usr/share/zsh/site-functions $fpath)
fi

for _zc_dir in /opt/homebrew/share/zsh-completions /usr/share/zsh/plugins/zsh-completions/src /usr/share/zsh-completions; do
  if [[ -d "$_zc_dir" ]]; then
    fpath=("$_zc_dir" $fpath)
    break
  fi
done
unset _zc_dir

autoload -Uz compinit
ZSH_CACHE_DIR="${XDG_CACHE_HOME}/zsh"
mkdir -p "$ZSH_CACHE_DIR"
if [[ -n "$ZSH_CACHE_DIR/zcompdump"(#qN.mh+24) ]]; then
  compinit -i -d "$ZSH_CACHE_DIR/zcompdump"
else
  compinit -C -d "$ZSH_CACHE_DIR/zcompdump"
fi
[[ "$ZSH_CACHE_DIR/zcompdump.zwc" -nt "$ZSH_CACHE_DIR/zcompdump" ]] \
  || zcompile "$ZSH_CACHE_DIR/zcompdump" &!

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' sort false
zstyle ':completion:*:descriptions' format '%F{yellow}── %d ──%f'
zstyle ':completion:*:warnings'     format '%F{red}No matches: %d%f'
zstyle ':completion:*:corrections'  format '%F{green}%d (errors: %e)%f'
zstyle ':completion:*:messages'     format '%F{purple}%d%f'
zstyle ':completion:*' verbose yes
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path "$ZSH_CACHE_DIR"
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion::complete:*' gain-privileges 1
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*:*:*:users' ignored-patterns \
  adm amanda apache at avahi avahi-autoipd beaglidx bin cacti canna \
  clamav daemon dbus distcache dnsmasq dovecot fax ftp games gdm \
  gkrellmd gopher hacluster haldaemon halt hsqldb ident junkbust \
  ldap lp mail mailman mailnull man messagebus mldonkey mysql nagios \
  named netdump news nfsnobody nobody 'ntp|ntpd' operator pcap \
  postfix postgres privoxy pulse pvm quagga radvd rpc rpcuser rpm \
  rsync shutdown squid sshd sync uucp vcsa xfs '_*'
zstyle ':completion:*:*:*:*:files' ignored-patterns '*?.pyc' '*?.o' '*~'
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories

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

autoload -Uz modify-current-argument
_single_quote_word() { modify-current-argument "'${ARG//\'/\\'\\''}'"; }
_double_quote_word() { modify-current-argument "\"${ARG}\""; }
zle -N _single_quote_word
zle -N _double_quote_word
bindkey "^['" _single_quote_word
bindkey '^["' _double_quote_word

autoload -Uz bracketed-paste-magic
zle -N bracketed-paste bracketed-paste-magic

_bind_history_search() {
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down
  bindkey '^P'   history-substring-search-up
  bindkey '^N'   history-substring-search-down
}

if command -v fzf &>/dev/null; then
  if [[ $_os == macos ]]; then
    _fzf_clip='pbcopy'
  elif command -v wl-copy &>/dev/null; then
    _fzf_clip='wl-copy'
  elif command -v xclip &>/dev/null; then
    _fzf_clip='xclip -selection clipboard'
  elif command -v xsel &>/dev/null; then
    _fzf_clip='xsel --clipboard --input'
  else
    _fzf_clip=''
  fi

  if command -v fd &>/dev/null; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
  else
    export FZF_DEFAULT_COMMAND='find . -type f -not -path "*/\.git/*"'
  fi

  # Bind values containing pipes/parens MUST be single-quoted in the
  # final string — otherwise fzf bails with "invalid command line string".
  _fzf_yank_bind=""
  [[ -n $_fzf_clip ]] && _fzf_yank_bind="--bind=ctrl-y:'execute-silent(echo {+} | $_fzf_clip)'"

  export FZF_DEFAULT_OPTS="
    --height=50%
    --layout=reverse
    --border=rounded
    --info=inline
    --prompt='❯ '
    --pointer=▶
    --marker=✓
    --bind=ctrl-/:toggle-preview
    --bind=ctrl-u:preview-half-page-up
    --bind=ctrl-d:preview-half-page-down
    --bind=ctrl-a:select-all
    $_fzf_yank_bind
    --bind=?:toggle-preview
    --color=bg+:#283457,bg:#1a1b26,spinner:#bb9af7,hl:#7aa2f7
    --color=fg:#c0caf5,header:#7aa2f7,info:#bb9af7,pointer:#7dcfff
    --color=marker:#9ece6a,fg+:#c0caf5,prompt:#bb9af7,hl+:#7aa2f7
    --color=border:#283457"

  if command -v bat &>/dev/null; then
    export FZF_CTRL_T_OPTS="
      --preview='bat --color=always --line-range :200 {}'
      --preview-window=right:55%:wrap"
  fi

  _fzf_history_yank_bind=""
  [[ -n $_fzf_clip ]] && \
    _fzf_history_yank_bind="--bind=ctrl-y:'execute-silent(echo -n {2..} | $_fzf_clip)+abort'"

  export FZF_CTRL_R_OPTS="
    --preview='echo {}'
    --preview-window=down:3:wrap
    $_fzf_history_yank_bind"

  unset _fzf_yank_bind _fzf_history_yank_bind

  if command -v eza &>/dev/null; then
    export FZF_ALT_C_OPTS="
      --preview='eza --icons --tree --level=2 --color=always {}'
      --preview-window=right:45%"
  else
    export FZF_ALT_C_OPTS="--preview='ls -la {}'"
  fi

  if [[ -f "$HOME/.fzf.zsh" ]]; then
    source "$HOME/.fzf.zsh" 2>/dev/null
  elif fzf --zsh &>/dev/null; then
    eval "$(fzf --zsh)" 2>/dev/null
  else
    for _fzf_root in /opt/homebrew/opt/fzf /usr/local/opt/fzf /usr/share/fzf; do
      if [[ -d "$_fzf_root/shell" ]]; then
        source "$_fzf_root/shell/key-bindings.zsh" 2>/dev/null
        source "$_fzf_root/shell/completion.zsh"   2>/dev/null
        break
      fi
    done
    unset _fzf_root
  fi
fi

# Plugin order is mandatory: autosuggestions → syntax-highlighting → history-substring-search.
# history-substring-search must be sourced last (per its own docs).
_source_first() {
  for _f in "$@"; do
    [[ -f "$_f" ]] && { source "$_f"; return 0; }
  done
  return 1
}

if _source_first \
  /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
  /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
  /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
then
  ZSH_AUTOSUGGEST_STRATEGY=(history completion)
  ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=40
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#565f89,underline"
  bindkey '^f'  autosuggest-accept
  bindkey '^]'  autosuggest-accept
  bindkey '^ '  autosuggest-accept
  bindkey '^[l' forward-word
fi

if _source_first \
  /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
  /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
  /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
then
  ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor)
  ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=red,bold'
  ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=cyan,bold'
  ZSH_HIGHLIGHT_STYLES[suffix-alias]='fg=green,underline'
  ZSH_HIGHLIGHT_STYLES[global-alias]='fg=blue,bold'
  ZSH_HIGHLIGHT_STYLES[command]='fg=green,bold'
  ZSH_HIGHLIGHT_STYLES[builtin]='fg=cyan'
  ZSH_HIGHLIGHT_STYLES[function]='fg=blue'
  ZSH_HIGHLIGHT_STYLES[path]='fg=white,underline'
  ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=yellow'
  ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=yellow'
  ZSH_HIGHLIGHT_STYLES[comment]='fg=#565f89'
  ZSH_HIGHLIGHT_STYLES[redirection]='fg=magenta'
  ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=cyan'
fi

if _source_first \
  /opt/homebrew/share/zsh-history-substring-search/zsh-history-substring-search.zsh \
  /usr/share/zsh-history-substring-search/zsh-history-substring-search.zsh \
  /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
then
  HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='bg=blue,fg=white,bold'
  HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND='bg=red,fg=white,bold'
  HISTORY_SUBSTRING_SEARCH_FUZZY=1
  HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1
  _bind_history_search
fi

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

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias -- -='cd -'
alias d='dirs -v'
for i in {1..9}; do alias "$i"="cd +$i"; done

if command -v eza &>/dev/null; then
  alias ls='eza --group-directories-first --icons=auto'
  alias ll='eza -lh  --git --group-directories-first --icons=auto'
  alias la='eza -lah --git --group-directories-first --icons=auto'
  alias lt='eza --tree --level=2 --long --icons --git'
  alias lta='eza --tree --level=2 --long --icons --git -a'
  alias l='eza -1 --group-directories-first'
else
  if [[ $_os == macos ]]; then
    alias ls='ls -G'
  else
    alias ls='ls --color=auto'
  fi
  alias ll='ls -lh'
  alias la='ls -lah'
  alias l='ls -CF'
fi

if command -v bat &>/dev/null; then
  alias cat='bat --paging=never'
  alias catp='bat'
  alias batp='bat --paging=always'
fi

if command -v rg &>/dev/null; then
  alias rg='rg --smart-case'
  alias rgs='rg --smart-case --hidden'
  alias rgl='rg --smart-case -l'
fi

command -v lazygit &>/dev/null && alias lg='lazygit'
command -v btop    &>/dev/null && alias top='btop'
command -v dust    &>/dev/null && alias usage='dust'
command -v procs   &>/dev/null && alias psa='procs'
command -v delta   &>/dev/null && alias deltadiff='diff -u'   # delta is a pager, not a diff(1) replacement
command -v duf     &>/dev/null && alias df='duf'
command -v tldr    &>/dev/null && alias help='tldr'

if command -v zoxide &>/dev/null; then
  alias j='cd'
  alias ji='cdi'
fi

alias g='git'
alias gs='git status -sb'
alias ga='git add'
alias gaa='git add --all'
alias gap='git add --patch'
alias gc='git commit -v'
alias gcm='git commit -m'
alias gca='git commit --amend --no-edit'
alias gcam='git commit --amend'
alias gd='git diff'
alias gds='git diff --staged'
alias gdc='git diff HEAD~1'
alias gl='git log --oneline --decorate --graph --all'
alias gll='git log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit'
alias gpu='git pull --rebase --autostash'
alias gps='git push'
alias gpf='git push --force-with-lease'
alias gpsu='git push --set-upstream origin HEAD'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gsw='git switch'
alias gswc='git switch -c'
alias gst='git stash'
alias gstp='git stash pop'
alias gstl='git stash list'
alias gsts='git stash show -p'
alias gf='git fetch --all --prune'
alias gm='git merge --no-ff'
alias grb='git rebase'
alias grbi='git rebase -i'
alias grba='git rebase --abort'
alias grbc='git rebase --continue'
alias gcp='git cherry-pick'
alias greset='git reset --soft HEAD~1'
alias gclean='git clean -fd'
alias gwip='git add -A && git commit -m "WIP: $(date +%H:%M)"'
alias gunwip='git log -n 1 --format="%s" | grep -q "^WIP" && git reset HEAD~1'
alias gbD='git branch -D'
alias gprune='git remote prune origin'

if command -v docker &>/dev/null; then
  alias dk='docker'
  alias dkc='docker compose'
  alias dkcu='docker compose up -d'
  alias dkcd='docker compose down'
  alias dkcr='docker compose restart'
  alias dkcl='docker compose logs -f'
  alias dkps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
  alias dkpsa='docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
  alias dkim='docker images'
  alias dkrm='docker rm'
  alias dkrmi='docker rmi'
  alias dkprune='docker system prune -af --volumes'
  alias dkexec='docker exec -it'
fi

alias t='tmux ls'
alias ta='tmux new-session -A -s'
alias td='tmux detach'
alias tks='tmux kill-session -t'
alias tka='tmux kill-server'
alias tw='tmux attach || tmux new -s Work'
alias tmuxrc='${EDITOR} ~/.config/tmux/tmux.conf'

alias ni='npm install'
alias nid='npm install --save-dev'
alias nr='npm run'
alias nrs='npm run start'
alias nrd='npm run dev'
alias nrb='npm run build'
alias nrt='npm run test'
alias nrl='npm run lint'
alias nrw='npm run watch'

alias py='python3'
alias pip='pip3'
alias venv='python3 -m venv .venv'
alias activate='source .venv/bin/activate 2>/dev/null || source venv/bin/activate 2>/dev/null'
ipy() {
  if python3 -c 'import IPython' &>/dev/null; then
    python3 -m IPython "$@"
  else
    python3 "$@"
  fi
}

alias decompress='tar -xzf'

alias mkdir='mkdir -pv'
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -iv'
alias du='du -sh'
alias path='print -l ${(s.:.)PATH}'
alias sz='du -sh * | sort -rh | head -20'

alias reload='source ~/.zshrc && echo "✓ zshrc reloaded"'
alias zshrc='${EDITOR} ~/.zshrc'
alias nvimrc='${EDITOR} ~/.config/nvim'
alias ghosttyrc='${EDITOR} ~/.config/ghostty/config'
alias starshiprc='${EDITOR} ~/GITHUB/dotfiles/starship/starship.toml'
alias dot='cd ~/GITHUB/dotfiles'
alias hosts='sudo ${EDITOR} /etc/hosts'
if command -v bat &>/dev/null; then
  alias ff="fzf --preview 'bat --style=numbers --color=always {}'"
else
  alias ff="fzf --preview 'cat {}'"
fi

alias myip='curl -s --max-time 5 https://ipinfo.io/ip'
alias ports='lsof -i -P -n | grep LISTEN'
alias ping='ping -c 5'
command -v wget &>/dev/null && alias wget='wget -c'

if [[ $_os == macos ]]; then
  alias localip='ipconfig getifaddr en0'
  alias flushdns='sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder && echo "DNS flushed"'
  alias brewup='brew update && brew upgrade && brew cleanup && echo "Homebrew updated"'
  alias brewdump='brew bundle dump --force --file=~/GITHUB/dotfiles/Brewfile && echo "Brewfile updated"'
  alias show='open .'
  alias hide='chflags hidden'
  alias unhide='chflags nohidden'
else
  alias localip='hostname -I | awk "{print \$1}"'
fi

n()        { command nvim "${@:-.}" }
mkcd()     { command mkdir -p -- "$1" && cd -- "$1" }
compress() { tar -czf "${1%/}.tar.gz" "${1%/}" }

extract() {
  if [[ -z "$1" ]]; then echo "Usage: extract <file>"; return 1; fi
  if [[ ! -f "$1" ]]; then echo "extract: '$1' is not a valid file"; return 1; fi
  case "$1" in
    *.tar.bz2)  tar xjf "$1"          ;;
    *.tar.gz)   tar xzf "$1"          ;;
    *.tar.xz)   tar xJf "$1"          ;;
    *.tar.zst)  tar --zstd -xf "$1"   ;;
    *.bz2)      bunzip2 "$1"          ;;
    *.rar)      unrar x "$1"          ;;
    *.gz)       gunzip "$1"           ;;
    *.tar)      tar xf "$1"           ;;
    *.tbz2)     tar xjf "$1"          ;;
    *.tgz)      tar xzf "$1"          ;;
    *.zip)      unzip "$1"            ;;
    *.Z)        uncompress "$1"       ;;
    *.7z)       7z x "$1"             ;;
    *.deb)      ar x "$1"             ;;
    *.xz)       unxz "$1"             ;;
    *.zst)      unzstd "$1"           ;;
    *) echo "extract: '$1' — unknown format"; return 1 ;;
  esac
}

up() {
  local n="${1:-1}" d=""
  for ((i=0; i<n; i++)); do d="../$d"; done
  cd "$d" || return
}

sizeof() { command du -sh "${1:-.}" | cut -f1 }
tre()    { eza --icons --tree --level="${1:-2}" "${@:2}" }
port()   { lsof -i ":${1}" }

fcd() {
  local dir preview _find_cmd
  if command -v eza &>/dev/null; then
    preview='eza --icons --tree --level=1 --color=always {}'
  else
    preview='ls -la {}'
  fi
  if command -v fd &>/dev/null; then
    _find_cmd='fd --type d --hidden --exclude .git'
  else
    _find_cmd='find . -type d -not -path "*/.git/*"'
  fi
  dir=$(eval "$_find_cmd" 2>/dev/null \
        | fzf --preview "$preview" --prompt '❯ ') && cd "$dir"
}

fkill() {
  local pid
  pid=$(ps aux | fzf --header='Select process to kill' --prompt='❯ ' | awk '{print $2}')
  [[ -n "$pid" ]] && kill -"${1:-9}" "$pid" && echo "Killed PID $pid"
}

fhist() {
  local cmd
  cmd=$(fc -l 1 | fzf --tac --prompt='❯ ' --preview='echo {}' | sed 's/ *[0-9]* *//')
  [[ -n "$cmd" ]] && print -z "$cmd"
}

fenv() { env | sort | fzf --prompt='❯ ' --preview='echo {}' }

eff() {
  local file
  file="$(ff)"
  [[ -n "$file" ]] && "$EDITOR" "$file"
}

fman() {
  man -k . 2>/dev/null \
    | fzf --prompt='man ❯ ' \
          --preview 'echo {} | awk "{print \$1}" | xargs man 2>/dev/null | head -80' \
    | awk '{print $1}' \
    | xargs man
}

gbr() {
  local branch
  branch=$(git branch -a --color=always \
           | grep -v '\->' \
           | fzf --ansi --preview 'git log --oneline --color=always {}' --prompt='branch ❯ ' \
           | sed 's/remotes\/origin\///' | tr -d ' *')
  [[ -n "$branch" ]] && git switch "$branch"
}

gshow() {
  git log --oneline --color=always "$@" \
  | fzf --ansi --no-sort --reverse \
        --preview 'git show --color=always {1}' \
        --bind 'enter:execute(git show --color=always {1} | less -R)' \
        --prompt='commit ❯ '
}

groot() {
  local root
  root=$(git rev-parse --show-toplevel 2>/dev/null) \
    || { echo "Not in a git repo"; return 1; }
  cd "$root"
}

gignore() {
  [[ -z "$1" ]] && { echo 'Usage: gignore <pattern>'; return 1; }
  echo "$1" >> .gitignore && echo "Added '$1' to .gitignore"
}

serve() { python3 -m http.server "${1:-8000}" }

json() {
  if [[ -p /dev/stdin ]]; then
    jq '.' < /dev/stdin
  elif [[ -n "$1" && -f "$1" ]]; then
    jq '.' "$1"
  elif [[ -n "$1" ]]; then
    jq '.' <<< "$1"
  else
    echo "Usage: json <file>, json '<string>', or pipe | json"
    return 1
  fi
}

cheat() { curl -s "cheat.sh/$1" | ${=PAGER:-less} }

dotenv() {
  local file="${1:-.env}"
  [[ ! -f "$file" ]] && { echo "dotenv: '$file' not found"; return 1; }
  set -o allexport
  source "$file"
  set +o allexport
  echo "Loaded $file"
}

httpstat() {
  curl -o /dev/null -s -w \
    "   dns: %{time_namelookup}s\n  conn: %{time_connect}s\n   tls: %{time_appconnect}s\n  send: %{time_pretransfer}s\n  wait: %{time_starttransfer}s\n total: %{time_total}s\n  size: %{size_download} bytes\nstatus: %{http_code}\n" \
    "$@"
}

fip() {
  (( $# < 2 )) && { echo 'Usage: fip <host> <port1> [port2] ...'; return 1; }
  local host="$1"; shift
  for port in "$@"; do
    ssh -f -N -L "$port:localhost:$port" "$host" \
      && echo "Forwarding localhost:$port → $host:$port"
  done
}

dip() {
  (( $# == 0 )) && { echo 'Usage: dip <port1> [port2] ...'; return 1; }
  for port in "$@"; do
    pkill -f "ssh.*-L $port:localhost:$port" \
      && echo "Stopped forwarding port $port" \
      || echo "No forwarding on port $port"
  done
}

lip() { pgrep -af "ssh.*-L [0-9]+:localhost:[0-9]+" || echo "No active forwards" }

if [[ $_os == linux ]] \
  && command -v lsblk &>/dev/null \
  && command -v omarchy-drive-select &>/dev/null \
  && command -v wipefs &>/dev/null \
  && command -v parted &>/dev/null \
  && command -v partprobe &>/dev/null \
  && command -v udevadm &>/dev/null \
  && command -v mkfs.exfat &>/dev/null
then
  iso2sd() {
    if (( $# < 1 )); then
      echo 'Usage: iso2sd <input_file> [output_device]'; return 1
    fi
    local iso="$1" drive="$2"
    if [[ -z $drive ]]; then
      local available_sds
      available_sds=$(lsblk -dpno NAME | grep -E '/dev/sd')
      [[ -z $available_sds ]] && { echo "No SD drives found"; return 1; }
      drive=$(omarchy-drive-select "$available_sds")
      [[ -z $drive ]] && { echo "No drive selected"; return 1; }
    fi
    sudo dd bs=4M status=progress oflag=sync if="$iso" of="$drive"
    sudo eject "$drive"
  }

  format-drive() {
    if (( $# != 2 )); then
      echo 'Usage: format-drive <device> <name>'; return 1
    fi
    echo "WARNING: This will completely erase all data on $1 and label it '$2'."
    read -rq "confirm?Are you sure? (y/N): "; echo
    [[ $confirm =~ ^[Yy]$ ]] || return 1
    sudo wipefs -a "$1"
    sudo dd if=/dev/zero of="$1" bs=1M count=100 status=progress
    sudo parted -s "$1" mklabel gpt
    sudo parted -s "$1" mkpart primary 1MiB 100%
    sudo parted -s "$1" set 1 msftdata on
    local partition="$([[ $1 == *nvme* ]] && echo "${1}p1" || echo "${1}1")"
    sudo partprobe "$1" || true
    sudo udevadm settle || true
    sudo mkfs.exfat -n "$2" "$partition"
    echo "Drive $1 formatted as exFAT and labeled '$2'."
  }
fi

if command -v ffmpeg &>/dev/null; then
  transcode-video-1080p() {
    ffmpeg -i "$1" -vf scale=1920:1080 -c:v libx264 -preset fast -crf 23 -c:a copy "${1%.*}-1080p.mp4"
  }
  transcode-video-4K() {
    ffmpeg -i "$1" -c:v libx265 -preset slow -crf 24 -c:a aac -b:a 192k "${1%.*}-optimized.mp4"
  }
  gif2mp4() {
    ffmpeg -i "$1" -vf "fps=15,scale=trunc(iw/2)*2:trunc(ih/2)*2" \
      -c:v libx264 -pix_fmt yuv420p -movflags faststart "${1%.*}.mp4"
  }
fi

if command -v magick &>/dev/null; then
  img2jpg()        { local img="$1"; shift; magick "$img" "$@" -quality 95 -strip "${img%.*}-converted.jpg"; }
  img2jpg-small()  { local img="$1"; shift; magick "$img" "$@" -resize 1080x\> -quality 95 -strip "${img%.*}-small.jpg"; }
  img2jpg-medium() { local img="$1"; shift; magick "$img" "$@" -resize 1800x\> -quality 95 -strip "${img%.*}-medium.jpg"; }
  img2png()        {
    local img="$1"; shift
    magick "$img" "$@" -strip \
      -define png:compression-filter=5 \
      -define png:compression-level=9 \
      -define png:compression-strategy=1 \
      -define png:exclude-chunk=all \
      "${img%.*}-optimized.png"
  }
fi

gwa() {
  [[ -z "$1" ]] && { echo 'Usage: gwa <branch-name>'; return 1; }
  local branch="$1"
  local path="../$(basename "$PWD")--${branch}"
  git worktree add -b "$branch" "$path"
  command -v mise &>/dev/null && mise trust "$path"
  cd "$path"
}

gwd() {
  if ! command -v gum &>/dev/null; then
    echo "gwd requires 'gum'. Install: brew install gum"; return 1
  fi
  if gum confirm "Remove worktree and branch?"; then
    local cwd="$(pwd)" worktree root branch
    worktree="$(basename "$cwd")"
    root="${worktree%%--*}"
    branch="${worktree#*--}"
    if [[ "$root" != "$worktree" ]]; then
      cd "../$root"
      git worktree remove "$cwd" --force || return 1
      git branch -D "$branch"
    else
      echo "Not in a worktree (no '--' in directory name)"
    fi
  fi
}

gwl() { git worktree list }

tdl() {
  [[ -z $1 ]] && { echo 'Usage: tdl <ai_command> [<second_ai>]'; return 1; }
  [[ -z $TMUX ]] && { echo "Must be inside tmux."; return 1; }
  local current_dir="$PWD" ai="$1" ai2="$2"
  local editor_pane="$TMUX_PANE" ai_pane ai2_pane
  tmux rename-window -t "$editor_pane" "$(basename "$current_dir")"
  tmux split-window -v -p 15 -t "$editor_pane" -c "$current_dir"
  ai_pane=$(tmux split-window -h -p 30 -t "$editor_pane" -c "$current_dir" -P -F '#{pane_id}')
  if [[ -n $ai2 ]]; then
    ai2_pane=$(tmux split-window -v -t "$ai_pane" -c "$current_dir" -P -F '#{pane_id}')
    tmux send-keys -t "$ai2_pane" "$ai2" C-m
  fi
  tmux send-keys -t "$ai_pane" "$ai" C-m
  tmux send-keys -t "$editor_pane" "$EDITOR ." C-m
  tmux select-pane -t "$editor_pane"
}

tdlm() {
  [[ -z $1 ]] && { echo 'Usage: tdlm <ai_command> [<second_ai>]'; return 1; }
  [[ -z $TMUX ]] && { echo "Must be inside tmux."; return 1; }
  local ai="$1" ai2="$2" base_dir="$PWD" first=true
  tmux rename-session "$(basename "$base_dir" | tr '.:' '--')"
  for dir in "$base_dir"/*/; do
    [[ -d $dir ]] || continue
    local dirpath="${dir%/}"
    if $first; then
      tmux send-keys -t "$TMUX_PANE" "cd '$dirpath' && tdl $ai $ai2" C-m
      first=false
    else
      local pane_id
      pane_id=$(tmux new-window -c "$dirpath" -P -F '#{pane_id}')
      tmux send-keys -t "$pane_id" "tdl $ai $ai2" C-m
    fi
  done
}

tsl() {
  [[ -z $1 || -z $2 ]] && { echo 'Usage: tsl <pane_count> <command>'; return 1; }
  [[ -z $TMUX ]] && { echo "Must be inside tmux."; return 1; }
  local count="$1" cmd="$2" current_dir="$PWD"
  local -a panes
  tmux rename-window -t "$TMUX_PANE" "$(basename "$current_dir")"
  panes+=("$TMUX_PANE")
  while (( ${#panes[@]} < count )); do
    local new_pane
    new_pane=$(tmux split-window -h -t "${panes[-1]}" -c "$current_dir" -P -F '#{pane_id}')
    panes+=("$new_pane")
    tmux select-layout -t "${panes[0]}" tiled
  done
  for pane in "${panes[@]}"; do tmux send-keys -t "$pane" "$cmd" C-m; done
  tmux select-pane -t "${panes[0]}"
}

if [[ $_os == macos ]]; then
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
fi

# eval-based hooks last so they override builtins.
command -v zoxide   &>/dev/null && eval "$(zoxide init zsh --cmd cd)"
command -v direnv   &>/dev/null && eval "$(direnv hook zsh)"
command -v mise     &>/dev/null && eval "$(mise activate zsh)"
command -v thefuck  &>/dev/null && eval "$(thefuck --alias)"
command -v atuin    &>/dev/null && eval "$(atuin init zsh --disable-up-arrow)"

autoload -Uz add-zsh-hook

# macOS APFS is case-insensitive but case-preserving — `cd github` succeeds
# when the folder is GITHUB and PWD reflects what you typed. This hook
# rewrites PWD to the on-disk casing after every cd. Symlinks are left intact.
if [[ $_os == macos ]]; then
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

  add-zsh-hook chpwd _fix_pwd_case
  _fix_pwd_case
fi

_set_terminal_title() {
  [[ -t 1 ]] || return
  local title="${PWD/#$HOME/~}"
  print -Pn "\e]0;${title}\a"
}
add-zsh-hook chpwd _set_terminal_title
_set_terminal_title
