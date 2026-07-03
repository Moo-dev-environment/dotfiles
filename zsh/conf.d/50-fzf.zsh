# fzf: env, key-binding integration, and all fzf-powered pickers.
# Loads AFTER 40-keybindings (fzf captures the existing ^I binding as
# fzf_default_completion) and after compinit (completion.zsh wraps it).

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

# ff is a function (was an alias) so sff/eff can call it at runtime and it can
# take extra fzf args.
ff() {
  local preview
  if command -v bat &>/dev/null; then
    preview='bat --style=numbers --color=always {}'
  else
    preview='cat {}'
  fi
  fzf --preview "$preview" "$@"
}

eff() {
  local file
  file="$(ff)"
  [[ -n "$file" ]] && "$EDITOR" "$file"
}

# scp the fuzzy-picked file (newest first) to a remote destination. Ported
# from Omarchy; GNU `find -printf` replaced with zsh glob qualifiers
# ('.' plain files, 'om' newest-first) so it works on macOS too.
sff() {
  (( $# )) || { echo 'Usage: sff <destination> (e.g. sff host:/tmp/)'; return 1 }
  local file
  file=$(print -rl -- **/*(.Nom) | ff) && [[ -n $file ]] && scp "$file" "$1"
}

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
  pid=$(ps aux | fzf --header-lines=1 --header='Select process to kill' --prompt='❯ ' | awk '{print $2}')
  [[ -n "$pid" ]] && kill -"${1:-9}" "$pid" && echo "Killed PID $pid"
}

fhist() {
  local cmd
  cmd=$(fc -l 1 | fzf --tac --prompt='❯ ' --preview='echo {}' | sed 's/ *[0-9]* *//')
  [[ -n "$cmd" ]] && print -z "$cmd"
}

fenv() { env | sort | fzf --prompt='❯ ' --preview='echo {}' }

fman() {
  man -k . 2>/dev/null \
    | fzf --prompt='man ❯ ' \
          --preview 'echo {} | awk "{print \$1}" | xargs man 2>/dev/null | head -80' \
    | awk '{print $1}' \
    | xargs man
}
