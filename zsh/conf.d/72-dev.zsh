# Dev stacks: docker, node, python, rails, AI CLIs.

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

# Omarchy shortcuts. Defined unconditionally (like Omarchy) — rails/opencode
# may only appear on PATH after mise activates, which happens later in 90-tools.
alias r='rails'
alias c='opencode'
alias cx='printf "\033[2J\033[3J\033[H" && claude --permission-mode bypassPermissions'
