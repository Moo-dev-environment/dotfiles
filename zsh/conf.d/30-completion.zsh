# Completion: fpath, compinit (24h cache + background zcompile), zstyles.
# fpath must be fully configured BEFORE compinit runs.

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
if [[ ! -f "$ZSH_CACHE_DIR/zcompdump" || -n "$ZSH_CACHE_DIR/zcompdump"(#qN.mh+24) ]]; then
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
