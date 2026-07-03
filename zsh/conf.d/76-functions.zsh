# Utility functions: files, dev helpers, SSH port forwarding.

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
  local n="${1:-1}" d="" i
  for ((i=0; i<n; i++)); do d="../$d"; done
  cd "$d" || return
}

sizeof() { command du -sh "${1:-.}" | cut -f1 }
tre()    { eza --icons --tree --level="${1:-2}" "${@:2}" }
port()   { lsof -i ":${1}" }

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

# SSH port forwarding (from Omarchy).
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

lip() {
  # pgrep -af prints full cmdline on Linux but only ancestors-included PIDs on
  # macOS, so use ps directly for a portable "PID + command" listing.
  local out
  out=$(ps -eo pid=,command= 2>/dev/null | awk '/[s]sh.*-L [0-9]+:localhost:[0-9]+/')
  [[ -n "$out" ]] && print -r -- "$out" || echo "No active forwards"
}
