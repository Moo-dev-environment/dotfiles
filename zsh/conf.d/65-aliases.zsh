# General aliases: navigation, listing, viewing, modern-tool swaps, safety,
# config shortcuts, network. (git → 70, dev stacks → 72, tmux → 74.)

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
  alias lsa='la'   # Omarchy muscle memory (its `lsa` = long + all)
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
  alias lsa='la'
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
if command -v delta &>/dev/null; then
  # delta is a pager, not a diff(1) replacement — wrap, don't alias `diff`.
  deltadiff() { command diff -u "$@" | delta }
fi
command -v duf     &>/dev/null && alias df='duf'
command -v tldr    &>/dev/null && alias help='tldr'

if command -v zoxide &>/dev/null; then
  alias j='cd'
  alias ji='cdi'
fi

alias decompress='tar -xzf'

alias mkdir='mkdir -pv'
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -iv'
alias du='du -sh'
alias path='print -l ${(s.:.)PATH}'
alias sz='du -sh * | sort -rh | head -20'

alias reload='source ~/.zshrc && echo "✓ zshrc reloaded"'
alias zshrc='${EDITOR} ${ZSH_CONFIG_DIR:-$HOME/GITHUB/dotfiles/zsh}'
alias nvimrc='${EDITOR} ~/.config/nvim'
alias ghosttyrc='${EDITOR} ~/.config/ghostty/config'
alias starshiprc='${EDITOR} ~/GITHUB/dotfiles/starship/starship.toml'
alias dot='cd ~/GITHUB/dotfiles'
alias hosts='sudo ${EDITOR} /etc/hosts'

alias myip='curl -s --max-time 5 https://ipinfo.io/ip'
alias ports='lsof -i -P -n | grep LISTEN'
alias ping='ping -c 5'
command -v wget &>/dev/null && alias wget='wget -c'
