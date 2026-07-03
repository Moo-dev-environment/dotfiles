# Git: aliases, fzf helpers, worktrees.

alias g='git'
alias gs='git status -sb'
alias ga='git add'
alias gaa='git add --all'
alias gap='git add --patch'
alias gc='git commit -v'
alias gcm='git commit -m'
alias gca='git commit --amend --no-edit'
alias gcam='git commit --amend'
alias gcad='git commit -a --amend'   # from Omarchy
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

# Worktrees (Omarchy's ga/gd, renamed — ga/gd are git add/diff here).
gwa() {
  [[ -z "$1" ]] && { echo 'Usage: gwa <branch-name>'; return 1; }
  local branch="$1"
  # NOT named `path` — in zsh that's the array tied to PATH, and localizing
  # it would clobber command lookup for the rest of the function.
  local wt_path="../$(basename "$PWD")--${branch}"
  git worktree add -b "$branch" "$wt_path"
  command -v mise &>/dev/null && mise trust "$wt_path"
  cd "$wt_path"
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
