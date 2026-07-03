# tmux: session aliases + dev layouts (tdl/tds/tdlm/tsl, from Omarchy).

alias t='tmux ls'
alias ta='tmux new-session -A -s'
alias td='tmux detach'
alias tks='tmux kill-session -t'
alias tka='tmux kill-server'
alias tw='tmux attach || tmux new -s Work'
alias tmuxrc='${EDITOR} ~/.config/tmux/tmux.conf'

# Shortcuts for the common tdl invocations (Omarchy).
alias ic='tdl c'
alias ix='tdl cx'
alias icx='tdl c cx'

# Dev layout: editor (big, left) + terminal strip (bottom) + 1–2 AI panes (right).
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

# Dev square: editor + diff watch on top, terminal + opencode below (Omarchy).
tds() {
  [[ -n $1 ]] && { echo 'Usage: tds'; return 1; }
  [[ -z $TMUX ]] && { echo "Must be inside tmux."; return 1; }
  local current_dir="$PWD"
  local editor_pane="$TMUX_PANE" diff_pane terminal_pane opencode_pane
  tmux rename-window -t "$editor_pane" "$(basename "$current_dir")"
  terminal_pane=$(tmux split-window -v -p 50 -t "$editor_pane" -c "$current_dir" -P -F '#{pane_id}')
  diff_pane=$(tmux split-window -h -p 50 -t "$editor_pane" -c "$current_dir" -P -F '#{pane_id}')
  opencode_pane=$(tmux split-window -h -p 50 -t "$terminal_pane" -c "$current_dir" -P -F '#{pane_id}')
  tmux send-keys -t "$editor_pane" -l "$EDITOR ."
  tmux send-keys -t "$editor_pane" C-m
  tmux send-keys -t "$diff_pane" -l "hunk diff --watch"
  tmux send-keys -t "$diff_pane" C-m
  tmux send-keys -t "$opencode_pane" -l "opencode"
  tmux send-keys -t "$opencode_pane" C-m
  tmux select-pane -t "$editor_pane"
}

# One tdl window per subdirectory (monorepo layout).
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

# Swarm layout: N tiled panes, same command in each.
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
