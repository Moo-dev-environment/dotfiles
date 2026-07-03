# Zsh Configuration Reference

Quick reference for all aliases, functions, keybindings, options, and tools
configured in this zsh setup.

## Table of Contents

- [File Structure](#file-structure)
- [Shell Options](#shell-options)
- [Key Bindings](#key-bindings)
- [Aliases](#aliases)
- [Functions](#functions)
- [Plugins](#plugins)
- [CLI Tools](#cli-tools)
- [FZF Shortcuts](#fzf-shortcuts)
- [Tool Integrations](#tool-integrations)
- [Cross-Platform Notes](#cross-platform-notes)
- [What Was Intentionally NOT Added](#what-was-intentionally-not-added)
- [Install Missing Tools](#install-missing-tools)

---

## File Structure

```
zsh/
  .zshrc            # Thin loader — sources conf.d/*.zsh in filename order
  .zprofile         # Login-shell hook (~/.local/bin/env toolchain shim)
  conf.d/           # The actual config, one numbered module per concern:
    00-os  10-env  20-options  30-completion  40-keybindings  50-fzf
    55-plugins  60-prompt  65-aliases  70-git  72-dev  74-tmux
    76-functions  78-media  80-linux  82-macos  88-hooks  90-tools
  README.md         # Install, ordering invariants, design notes
  REFERENCE.md      # This file — full cheatsheet
```

`~/.zshrc.local` (untracked) is sourced last for machine-local overrides.

See **[README.md](README.md)** for the load order, ordering invariants,
and rationale behind non-obvious choices (FZF bind quoting,
fzf-completion + `**` trigger, macOS path canonicalization, etc.).

---

## Shell Options

### Directory Navigation

| Option              | What it does                                         |
|---------------------|------------------------------------------------------|
| `auto_cd`           | Type a directory name to cd into it (no `cd` needed) |
| `auto_pushd`        | Every cd pushes onto the directory stack             |
| `pushd_ignore_dups` | No duplicate entries in the directory stack          |
| `pushd_silent`      | Don't print the stack on pushd/popd                  |
| `cdable_vars`       | `cd VARNAME` works if VARNAME holds a path           |

### Completion

| Option             | What it does                                          |
|--------------------|-------------------------------------------------------|
| `complete_in_word` | Complete from cursor position, not just end of word   |
| `always_to_end`    | Move cursor to end of word after completion           |
| `list_packed`      | Compact completion list (less vertical space)         |
| `menu_complete`    | Auto-select first match on first Tab press            |

### Globbing

| Option          | What it does                                                          |
|-----------------|-----------------------------------------------------------------------|
| `extended_glob` | Extended patterns: `^*.log` (not .log), `**/*.ts`, `#` quantifiers   |
| `glob_dots`     | `*` and `**` also match dotfiles — affects `rm *` too, by design     |
| `null_glob`     | No error when a glob matches nothing (expands to empty)               |

### History

| Option                    | What it does                                               |
|---------------------------|------------------------------------------------------------|
| `extended_history`        | Save timestamp and duration alongside each entry           |
| `hist_expire_dups_first`  | Expire duplicate entries first when history is full        |
| `hist_ignore_all_dups`    | Remove ALL older duplicates (not just consecutive)         |
| `hist_ignore_space`       | Prefix a command with a space to exclude it from history   |
| `hist_find_no_dups`       | Don't show duplicates when searching history               |
| `hist_reduce_blanks`      | Strip extra whitespace from saved commands                 |
| `hist_save_no_dups`       | Don't write duplicates to the history file                 |
| `hist_verify`             | Show recalled command before executing (lets you edit)     |
| `append_history`          | Append to history file, don't overwrite                    |
| `share_history`           | Share history across all sessions in real time; also handles incremental appending — `inc_append_history` is intentionally omitted alongside it to avoid duplicate/disordered history |

```
HISTFILE   ~/.zsh_history
HISTSIZE   200,000
SAVEHIST   200,000
```

**Tip:** prefix a sensitive command with a space and it won't appear in history.

### Safety & Misc

| Option                 | What it does                                               |
|------------------------|------------------------------------------------------------|
| `interactive_comments` | Allow `#` comments in interactive shell                    |
| `no_beep`              | Silence the terminal bell                                  |
| `rm_star_wait`         | 10-second pause before `rm *` (Ctrl-C to cancel)          |
| `prompt_subst`         | Allow variable expansion in the prompt                     |
| `long_list_jobs`       | Show PID in job notifications                              |
| `notify`               | Report job status immediately when a background job exits  |
| `no_hup`               | Don't kill background jobs when the shell exits            |
| `no_check_jobs`        | Don't warn about running jobs on exit                      |
| `multios`              | Allow multiple redirections (`cmd > a > b` works like tee) |
| `correct`              | Offer spelling corrections for mistyped commands           |
| `no_correct_all`       | But NOT for arguments — too noisy in practice              |

`REPORTTIME=10` — zsh prints timing info automatically for any command that takes
longer than 10 seconds.

### WORDCHARS (Ctrl-W behaviour)

`/`, `=`, and `:` are removed from `WORDCHARS` so that Ctrl-W stops at path
separators, `=` in env-var assignments, and `:` in URLs.

---

## Key Bindings

Uses **emacs mode** (`bindkey -e`).

### Line Editing

| Binding         | Action                                              |
|-----------------|-----------------------------------------------------|
| `Ctrl-A`        | Beginning of line                                   |
| `Ctrl-E`        | End of line                                         |
| `Home`          | Beginning of line                                   |
| `End`           | End of line                                         |
| `Ctrl-W`        | Delete word backward (stops at `/` `=` `:`)         |
| `Alt-D`         | Delete word forward                                 |
| `Ctrl-K`        | Kill to end of line                                 |
| `Ctrl-Y`        | Yank (paste) killed text                            |
| `Ctrl-/`        | Undo                                                |
| `Alt-Ctrl-/`    | Redo                                                |
| `Alt-F`         | Move forward one word                               |
| `Alt-B`         | Move backward one word                              |
| `Ctrl-Right`    | Move forward one word                               |
| `Ctrl-Left`     | Move backward one word                              |
| `Delete`        | Forward delete character                            |
| `Ctrl-X Ctrl-E` | Open current command in `$EDITOR`                   |
| `Ctrl-Q`        | Park current command, run another, then restore it  |

### Quoting

| Binding | Action                             |
|---------|------------------------------------|
| `Alt-'` | Wrap current word in single quotes |
| `Alt-"` | Wrap current word in double quotes |

### Autosuggestions

| Binding       | Action                               | Notes                            |
|---------------|--------------------------------------|----------------------------------|
| `Ctrl-F`      | Accept full suggestion               | Primary — works inside tmux      |
| `Ctrl-]`      | Accept full suggestion               | Alternative                      |
| `Ctrl-Space`  | Accept full suggestion               | Outside tmux only                |
| `Alt-L`       | Accept one word of suggestion        | Step through word by word        |

### History Search

| Binding      | Action                               |
|--------------|--------------------------------------|
| `Up Arrow`   | History substring search up          |
| `Down Arrow` | History substring search down        |
| `Ctrl-P`     | History substring search up          |
| `Ctrl-N`     | History substring search down        |

### FZF Bindings

| Binding  | Action                  |
|----------|-------------------------|
| `Ctrl-T` | Insert file path        |
| `Ctrl-R` | Search command history  |
| `Alt-C`  | cd into directory       |

---

## Aliases

Bypass any alias with a leading backslash:
`\ls`, `\rm`, `\cat`.

### Navigation

| Alias   | Expands to     | Notes                             |
|---------|----------------|-----------------------------------|
| `..`    | `cd ..`        |                                   |
| `...`   | `cd ../..`     |                                   |
| `....`  | `cd ../../..`  |                                   |
| `-`     | `cd -`         | Go back to previous directory     |
| `d`     | `dirs -v`      | Show numbered directory stack     |
| `1`–`9` | `cd +N`        | Jump to Nth entry in dir stack    |
| `j`     | `cd`           | Zoxide-enhanced cd shorthand      |
| `ji`    | `cdi`          | Interactive zoxide (fzf picker)   |

### File Listing

With `eza` (preferred):

| Alias | What it does                                         |
|-------|------------------------------------------------------|
| `ls`  | `eza --icons --group-directories-first`              |
| `l`   | Single-column listing                                |
| `ll`  | Long listing with git status and icons               |
| `la`  | Long listing including hidden files                  |
| `lsa` | Same as `la` (Omarchy muscle memory)                 |
| `lt`  | Tree view, 2 levels deep (long, with git)            |
| `lta` | Tree view, 2 levels deep (include hidden)            |

Fallback (`ls`): `ls -G` (macOS) or `ls --color=auto` (Linux).

### File Viewing

| Alias   | What it does                         | Requires |
|---------|--------------------------------------|----------|
| `cat`   | `bat --paging=never`                 | bat      |
| `catp`  | `bat` (with default paging)          | bat      |
| `batp`  | `bat --paging=always`                | bat      |

(`ff` is now a **function** — see [FZF-Powered Interactive](#fzf-powered-interactive).)

### Modern CLI Replacements

| Alias   | Replaces | Tool      | Notes                                       |
|---------|----------|-----------|---------------------------------------------|
| `rg`    | `grep`   | ripgrep   | Smart-case by default                       |
| `rgs`   | —        | ripgrep   | Also searches hidden/ignored files          |
| `rgl`   | —        | ripgrep   | List matching files only                    |
| `deltadiff` | —    | delta     | `diff -u` piped through delta (not aliased over `diff(1)`) |
| `df`    | `df`     | duf       | Nicer disk usage summary                    |
| `top`   | `top`    | btop      | Modern system monitor                       |
| `usage` | `du`     | dust      | Visual disk usage tree                      |
| `psa`   | `ps`     | procs     | Colored process viewer                      |
| `help`  | `man`    | tldr      | Concise community-written man pages         |
| `lg`    | —        | lazygit   | Interactive git TUI                         |

### Archive

| Alias        | What it does                     |
|--------------|----------------------------------|
| `decompress` | `tar -xzf` — extract a .tar.gz  |

Use `compress <dir>` (function) to create a `.tar.gz`. Use `extract <file>` for
any archive format.

### Git

| Alias    | Expands to                              | Notes                               |
|----------|-----------------------------------------|-------------------------------------|
| `g`      | `git`                                   |                                     |
| `gs`     | `git status -sb`                        | Short status with branch info       |
| `ga`     | `git add`                               |                                     |
| `gaa`    | `git add --all`                         |                                     |
| `gap`    | `git add --patch`                       | Interactive hunk staging            |
| `gc`     | `git commit -v`                         | Verbose (shows diff in editor)      |
| `gcm`    | `git commit -m`                         |                                     |
| `gca`    | `git commit --amend --no-edit`          | Amend without changing message      |
| `gcam`   | `git commit --amend`                    | Amend with message edit             |
| `gcad`   | `git commit -a --amend`                 | Stage tracked changes + amend (Omarchy) |
| `gd`     | `git diff`                              |                                     |
| `gds`    | `git diff --staged`                     |                                     |
| `gdc`    | `git diff HEAD~1`                       | Diff vs previous commit             |
| `gl`     | `git log --oneline --graph --all`       | Compact graph log                   |
| `gll`    | `git log --graph --pretty=...`          | Detailed colored graph log          |
| `gpu`    | `git pull --rebase --autostash`         | Clean pull: rebase + auto-stash     |
| `gps`    | `git push`                              |                                     |
| `gpf`    | `git push --force-with-lease`           | Safe force push                     |
| `gpsu`   | `git push --set-upstream origin HEAD`   | Push new branch + set upstream      |
| `gco`    | `git checkout`                          |                                     |
| `gcb`    | `git checkout -b`                       | Create and switch to new branch     |
| `gsw`    | `git switch`                            |                                     |
| `gswc`   | `git switch -c`                         | Create and switch to new branch     |
| `gst`    | `git stash`                             |                                     |
| `gstp`   | `git stash pop`                         |                                     |
| `gstl`   | `git stash list`                        |                                     |
| `gsts`   | `git stash show -p`                     | Show stash diff                     |
| `gf`     | `git fetch --all --prune`               | Fetch all remotes, prune deleted    |
| `gm`     | `git merge --no-ff`                     | Always create a merge commit        |
| `grb`    | `git rebase`                            |                                     |
| `grbi`   | `git rebase -i`                         | Interactive rebase                  |
| `grba`   | `git rebase --abort`                    |                                     |
| `grbc`   | `git rebase --continue`                 |                                     |
| `gcp`    | `git cherry-pick`                       |                                     |
| `greset` | `git reset --soft HEAD~1`               | Undo last commit, keep changes      |
| `gclean` | `git clean -fd`                         | Remove untracked files/dirs         |
| `gwip`   | `git add -A && git commit -m "WIP:..."` | Quick WIP commit with timestamp     |
| `gunwip` | Undo a WIP commit if HEAD is WIP        |                                     |
| `gbD`    | `git branch -D`                         | Force-delete a local branch         |
| `gprune` | `git remote prune origin`               | Clean stale remote-tracking refs    |

### Docker

| Alias     | Expands to                          | Notes                         |
|-----------|-------------------------------------|-------------------------------|
| `dk`      | `docker`                            |                               |
| `dkc`     | `docker compose`                    |                               |
| `dkcu`    | `docker compose up -d`              | Detached mode                 |
| `dkcd`    | `docker compose down`               |                               |
| `dkcr`    | `docker compose restart`            |                               |
| `dkcl`    | `docker compose logs -f`            | Follow logs                   |
| `dkps`    | `docker ps --format "table ..."`    | Clean table output            |
| `dkpsa`   | `docker ps -a --format ...`         | Include stopped containers    |
| `dkim`    | `docker images`                     |                               |
| `dkrm`    | `docker rm`                         |                               |
| `dkrmi`   | `docker rmi`                        |                               |
| `dkprune` | `docker system prune -af --volumes` | Remove all unused + volumes   |
| `dkexec`  | `docker exec -it`                   | Exec into a container         |

### Tmux

| Alias    | Expands to                           | Notes                          |
|----------|--------------------------------------|--------------------------------|
| `t`      | `tmux ls`                            | List sessions                  |
| `ta`     | `tmux new-session -A -s`             | Attach or create named session |
| `td`     | `tmux detach`                        |                                |
| `tks`    | `tmux kill-session -t`               |                                |
| `tka`    | `tmux kill-server`                   |                                |
| `tw`     | `tmux attach \|\| tmux new -s Work`  | Quick attach or create Work    |
| `tmuxrc` | Open tmux config in `$EDITOR`        |                                |
| `ic`     | `tdl c`                              | Dev layout + opencode          |
| `ix`     | `tdl cx`                             | Dev layout + claude (bypass)   |
| `icx`    | `tdl c cx`                           | Dev layout + both AIs          |

### AI / App shortcuts (Omarchy)

| Alias | Expands to                                        | Notes                          |
|-------|---------------------------------------------------|--------------------------------|
| `c`   | `opencode`                                        |                                |
| `cx`  | clear screen + `claude --permission-mode bypassPermissions` |                      |
| `r`   | `rails`                                           |                                |

### Node / npm

| Alias | Expands to               |
|-------|--------------------------|
| `ni`  | `npm install`            |
| `nid` | `npm install --save-dev` |
| `nr`  | `npm run`                |
| `nrs` | `npm run start`          |
| `nrd` | `npm run dev`            |
| `nrb` | `npm run build`          |
| `nrt` | `npm run test`           |
| `nrl` | `npm run lint`           |
| `nrw` | `npm run watch`          |

### Python

| Alias      | Expands to                                          | Notes                          |
|------------|-----------------------------------------------------|--------------------------------|
| `py`       | `python3`                                           |                                |
| `pip`      | `pip3`                                              |                                |
| `venv`     | `python3 -m venv .venv`                             | Create venv in current dir     |
| `activate` | `source .venv/bin/activate` (or `venv/bin/activate`)| Auto-finds either path         |
| `ipy`      | `python3 -m IPython` (falls back to `python3`)      |                                |

### Safety & Filesystem

| Alias   | Expands to  | Notes                                        |
|---------|-------------|----------------------------------------------|
| `cp`    | `cp -iv`    | Interactive + verbose (bypass with `\cp`)    |
| `mv`    | `mv -iv`    | Interactive + verbose (bypass with `\mv`)    |
| `rm`    | `rm -iv`    | Interactive + verbose (bypass with `\rm`)    |
| `mkdir` | `mkdir -pv` | Create parents automatically + verbose       |
| `du`    | `du -sh`    | Human-readable size of current dir           |
| `sz`    | —           | Top-20 sizes in current directory            |

### Config & Network

| Alias        | What it does                                  |
|--------------|-----------------------------------------------|
| `path`       | Pretty-print PATH (one entry per line)        |
| `reload`     | Re-source `~/.zshrc`                          |
| `zshrc`      | Open `.zshrc` in `$EDITOR`                   |
| `nvimrc`     | Open Neovim config in `$EDITOR`               |
| `ghosttyrc`  | Open Ghostty config in `$EDITOR`              |
| `starshiprc` | Open Starship config in `$EDITOR`             |
| `dot`        | `cd ~/GITHUB/dotfiles`                        |
| `hosts`      | Edit `/etc/hosts` with sudo                   |
| `myip`       | Show public IP address (via ipinfo.io)        |
| `localip`    | Show local IP address                         |
| `ports`      | Show all listening ports                      |
| `ping`       | `ping -c 5` (5 packets then stop)             |
| `wget`       | `wget -c` (continue interrupted downloads)   |
| `ff`         | fzf file picker with syntax preview           |

### macOS Only

| Alias       | What it does                              |
|-------------|-------------------------------------------|
| `flushdns`  | Flush DNS cache                           |
| `brewup`    | `brew update && upgrade && cleanup`       |
| `brewdump`  | Export Brewfile to dotfiles               |
| `show`      | `open .` — reveal current dir in Finder  |
| `hide`      | `chflags hidden <file>`                   |
| `unhide`    | `chflags nohidden <file>`                 |

---

## Functions


### File & Directory

| Function   | Usage                    | What it does                                          |
|------------|--------------------------|-------------------------------------------------------|
| `n`        | `n` or `n src/`          | Open nvim in current dir (or given path)              |
| `mkcd`     | `mkcd project-name`      | `mkdir -p` + `cd` in one step                         |
| `compress` | `compress my-dir`        | Create `my-dir.tar.gz`                                |
| `extract`  | `extract archive.tar.gz` | Universal extractor (tar/zip/gz/bz2/xz/zst/7z/rar/…) |
| `up`       | `up 3`                   | Go up N directories (default 1)                       |
| `sizeof`   | `sizeof node_modules`    | Human-readable size of file or directory              |
| `tre`      | `tre 3 src/`             | eza tree view with configurable depth                 |
| `port`     | `port 3000`              | Show what's listening on a given port                 |

### FZF-Powered Interactive

| Function | Usage             | What it does                                          |
|----------|-------------------|-------------------------------------------------------|
| `ff`     | `ff` (or pipe in) | fzf file picker with `bat` preview (plain `cat` fallback) |
| `eff`    | `eff`             | fzf-pick a file then open in `$EDITOR`                |
| `sff`    | `sff host:/tmp/`  | fzf-pick newest file, `scp` it to a remote (Omarchy)  |
| `fcd`    | `fcd`             | Fuzzy cd into any subdirectory (fd or find backend)   |
| `fkill`  | `fkill`           | Interactively select and kill a process               |
| `fhist`  | `fhist`           | Fuzzy search history, place selection in input buffer |
| `fenv`   | `fenv`            | Fuzzy search environment variables                    |
| `fman`   | `fman`            | Fuzzy search man pages with preview                   |

### Git

| Function  | Usage          | What it does                                       |
|-----------|----------------|----------------------------------------------------|
| `gbr`     | `gbr`          | FZF branch switcher (local + remote)               |
| `gshow`   | `gshow`        | FZF commit browser with diff preview               |
| `groot`   | `groot`        | cd to repository root                              |
| `gignore` | `gignore *.log`| Append pattern to `.gitignore`                     |
| `gwa`     | `gwa <branch>` | Create a new git worktree + branch, then cd into it|
| `gwd`     | `gwd`          | Remove current worktree and its branch (uses gum)  |
| `gwl`     | `gwl`          | List worktrees with status                         |

### Development

| Function    | Usage                      | What it does                              |
|-------------|----------------------------|-------------------------------------------|
| `serve`     | `serve` or `serve 3000`    | HTTP server in current directory          |
| `json`      | `json file.json` or pipe   | Pretty-print JSON via jq                  |
| `cheat`     | `cheat tar`                | Command cheat sheet from cheat.sh         |
| `dotenv`    | `dotenv` or `dotenv .env.local` | Load `.env` file into current shell  |
| `httpstat`  | `httpstat https://...`     | curl with full DNS/connect/TLS breakdown  |

### Port Forwarding (SSH)

| Function | Usage                          | What it does                                    |
|----------|--------------------------------|-------------------------------------------------|
| `fip`    | `fip myserver 3000 5432`       | Forward remote ports to localhost over SSH      |
| `dip`    | `dip 3000`                     | Stop forwarding for a given port                |
| `lip`    | `lip`                          | List all active SSH port forwards               |

### Tmux Layouts

| Function | Usage                       | What it does                                               |
|----------|-----------------------------|------------------------------------------------------------|
| `tdl`    | `tdl claude` or `tdl claude aider` | Dev layout: editor left, one or two AI panes right  |
| `tds`    | `tds`                       | Dev square: editor + `hunk diff --watch` / terminal + opencode (Omarchy) |
| `tdlm`   | `tdlm claude`               | One `tdl` window per subdirectory (monorepo layout)        |
| `tsl`    | `tsl 3 claude`              | N panes side-by-side, same command in each (swarm layout)  |

### Media (requires ffmpeg / imagemagick)

| Function             | Usage                     | What it does                              |
|----------------------|---------------------------|-------------------------------------------|
| `transcode-video-1080p` | `transcode-video-1080p in.mp4` | Re-encode to 1080p H.264           |
| `transcode-video-4K` | `transcode-video-4K in.mp4` | Re-encode to 4K H.265                   |
| `gif2mp4`            | `gif2mp4 anim.gif`        | Convert animated GIF to small mp4         |
| `img2jpg`            | `img2jpg photo.png`       | Convert image to high-quality JPG         |
| `img2jpg-small`      | `img2jpg-small photo.png` | Convert + resize to max 1080px wide       |
| `img2jpg-medium`     | `img2jpg-medium photo.png`| Convert + resize to max 1800px wide       |
| `img2png`            | `img2png photo.jpg`       | Convert to optimized PNG                  |

### Linux Only

| Function       | Usage                          | What it does                               |
|----------------|--------------------------------|--------------------------------------------|
| `iso2sd`       | `iso2sd image.iso [/dev/sdX]`  | Flash ISO to SD card / USB drive           |
| `format-drive` | `format-drive /dev/sdX LABEL`  | Wipe and format a drive as exFAT           |

### macOS Only

| Function | Usage         | What it does                                   |
|----------|---------------|------------------------------------------------|
| `hidden` | `hidden`      | Toggle hidden files on/off in Finder           |
| `ql`     | `ql file.pdf` | Quick Look a file without leaving the terminal |
| `notify` | `notify "Done"` | Send a macOS notification from the terminal  |

---

## Plugins

No plugin manager — sourced directly
from system paths (Homebrew, Arch, Debian/Ubuntu).

**Source order is mandatory:**
1. `zsh-autosuggestions` — must come before syntax-highlighting
2. `zsh-syntax-highlighting` — must come before history-substring-search
3. `zsh-history-substring-search` — must be sourced last (per its docs)

| Plugin                          | Purpose                                        |
|---------------------------------|------------------------------------------------|
| `zsh-autosuggestions`           | Ghost-text suggestions from history/completion |
| `zsh-syntax-highlighting`       | Fish-like command coloring as you type         |
| `zsh-history-substring-search`  | Up/Down arrows search by what you've typed     |

Autosuggestion strategy: `(history completion)` — tries history first, then
completion engine.

---

## CLI Tools

Modern replacements for standard unix tools. All aliases degrade gracefully
when a tool isn't installed.

| Tool        | Replaces  | Purpose                                          |
|-------------|-----------|--------------------------------------------------|
| `bat`       | `cat`     | Syntax-highlighted file viewer with pager        |
| `eza`       | `ls`      | Modern ls with icons, git status, tree view      |
| `fd`        | `find`    | Fast, `.gitignore`-aware file finder             |
| `fzf`       | —         | Fuzzy finder for files, history, directories     |
| `ripgrep`   | `grep`    | Fast content search, respects `.gitignore`       |
| `delta`     | `diff`    | Git diff with syntax highlighting                |
| `duf`       | `df`      | Visual disk usage summary                        |
| `zoxide`    | `cd`      | Frecency-based directory jumper                  |
| `direnv`    | —         | Per-directory `.envrc` environment loading       |
| `mise`      | nvm/pyenv | Dev tool version manager (node, python, go, …)   |
| `starship`  | —         | Fast, cross-shell customizable prompt            |
| `lazygit`   | —         | Interactive git TUI                              |
| `jq`        | —         | JSON processor                                   |
| `atuin`     | —         | Shell history sync across machines (optional)    |
| `thefuck`   | —         | Auto-corrects previous mistyped command          |
| `btop`      | `top`     | Modern system monitor                            |
| `dust`      | `du`      | Visual disk usage tree                           |
| `procs`     | `ps`      | Colored process viewer                           |
| `tldr`      | `man`     | Concise community man pages (`help <cmd>`)       |
| `gum`       | —         | Required by `gwd` (worktree removal)             |

---

## FZF Shortcuts

Backend: `fd` (falls back to `find`).

| Shortcut  | What it does                    | Preview window                    |
|-----------|---------------------------------|-----------------------------------|
| `Ctrl-T`  | Insert file path at cursor      | bat syntax highlight (right 55%)  |
| `Ctrl-R`  | Search command history          | Full command (bottom 3 lines)     |
| `Alt-C`   | cd into a directory             | eza tree, 2 levels (right 45%)    |

### Inside any FZF window

| Key       | Action                              |
|-----------|-------------------------------------|
| `Ctrl-/`  | Toggle preview pane                 |
| `?`       | Toggle preview pane (alternate)     |
| `Ctrl-U`  | Scroll preview up half page         |
| `Ctrl-D`  | Scroll preview down half page       |
| `Ctrl-A`  | Select all entries                  |
| `Ctrl-Y`  | Copy selection to clipboard         |

Color theme: **Tokyo Night** (consistent with bat, delta, starship, terminal).

---

## Tool Integrations

These use `eval` hooks and are placed last in `.zshrc`
so they can override builtins after all other config is loaded.

| Tool      | Behaviour                                                                     |
|-----------|-------------------------------------------------------------------------------|
| `zoxide`  | Replaces `cd` with a frecency-aware version. `cdi` opens an fzf picker.      |
| `direnv`  | Auto-loads/unloads `.envrc` when you cd in and out of a directory.            |
| `mise`    | Activates per-project tool versions from `.tool-versions` or `.mise.toml`.   |
| `thefuck` | Corrects the previous command; use the `fuck` command after a typo.           |
| `atuin`   | Replaces `Ctrl-R` with a TUI that syncs history across machines (if installed). Up-arrow is left for history-substring-search. |
| `try`     | Scratch project dirs under `~/Work/tries` (Omarchy). Lazy-loaded: first call pays the init cost, startup pays nothing. |

Terminal title is also updated on `chpwd` to show the current directory
(works in xterm-compatible terminals, iTerm2, Ghostty).

---

## Cross-Platform Notes

### OS Detection (`_os`)

Set in `conf.d/00-os.zsh`, referenced throughout all modules.

| Value   | When                                                            |
|---------|-----------------------------------------------------------------|
| `macos` | `$OSTYPE` matches `darwin*`                                     |
| `wsl`   | Linux kernel with `$WSL_DISTRO_NAME` set or WSLInterop present  |
| `linux` | Native Linux (not WSL)                                          |
| `other` | Anything else (BSD, etc.)                                       |

### Locale

`LANG=en_US.UTF-8` is set unconditionally. `LC_ALL` is only forced on macOS,
where the locale is always present. On Linux/WSL/containers it's left unset —
avoids `setlocale` warnings when `en_US.UTF-8` hasn't been generated.

### fzf Clipboard (`Ctrl-Y`)

Auto-detected at shell startup, checked in this order:

| Platform       | Tool       | Install                          |
|----------------|------------|----------------------------------|
| macOS          | `pbcopy`   | built-in                         |
| Linux (Wayland)| `wl-copy`  | `sudo apt install wl-clipboard`  |
| Linux (X11)    | `xclip`    | `sudo apt install xclip`         |
| Linux (X11)    | `xsel`     | `sudo apt install xsel`          |
| Not found      | (omitted)  | no binding, no error             |

### Fallbacks

Every tool-replacing alias falls back to a standard tool when the modern
replacement isn't installed. Core operations always work.

---

## What Was Intentionally NOT Added

| Suggestion                | Why it was skipped                                                         |
|---------------------------|----------------------------------------------------------------------------|
| `noclobber`               | Breaks common `>` redirect patterns; forces `>\|` for overwrites. Not worth the friction. |
| `fzf-tab`                 | Conflicts with `menu select` completion. Would require removing current zstyle rules. |
| `broot`                   | Already covered by fzf + fd + eza (same use case: file navigation/search). |
| `autojump` / `fasd`       | Older, slower alternatives to zoxide (already installed).                  |
| `zsh-defer`               | Shell startup is already fast. No performance problem to solve.             |
| `fast-syntax-highlighting`| Marginal speed difference vs zsh-syntax-highlighting at this config size.  |
| `zsh-vi-mode`             | Would change the emacs-mode workflow. Major habit change, not an improvement. |
| XDG `ZDOTDIR` relocation  | Modularity is done via `conf.d/` sourcing instead — no `.zshenv` bootstrap needed, `~/.zshrc` stays a plain symlink. |
| `omarchy-transcode` delegation | That binary only exists on Omarchy; the inline ffmpeg/imagemagick functions are portable. |
| `inc_append_history`      | `share_history` already writes entries incrementally. Enabling both causes confusing ordering and apparent duplicates across concurrent shells. |
| `url-quote-magic`         | Binding it to `self-insert` causes typing lag in modern terminals. `bracketed-paste-magic` alone handles safe pasting. |

---

## Install Missing Tools

### macOS (Homebrew)

```sh
# Core
brew install bat eza fd fzf ripgrep delta zoxide direnv mise starship lazygit jq

# Completions + extras
brew install zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search \
             zsh-completions btop dust procs tldr gum thefuck atuin

# Docker extras (if needed)
brew install duf

# Media
brew install ffmpeg imagemagick
```

### Linux (Debian/Ubuntu)

```sh
sudo apt install bat eza fd-find fzf ripgrep zoxide direnv jq \
                 zsh-autosuggestions zsh-syntax-highlighting \
                 zsh-history-substring-search wl-clipboard

# Tools not in apt: starship, mise, lazygit, delta, btop, dust, procs, atuin
# Install via their official installers or cargo
curl -sS https://starship.rs/install.sh | sh
curl https://mise.run | sh
```

### Optional: Tokyo Night theme for bat

`BAT_THEME` falls back to the built-in `ansi` unless the theme is properly
installed (file present **and** cache built):

```sh
mkdir -p ~/.config/bat/themes && cd ~/.config/bat/themes
curl -LO https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/sublime/tokyonight_night.tmTheme
bat cache --build
```

### Rebuild completion cache after installing new tools

```sh
rm -f ~/.cache/zsh/zcompdump && source ~/.zshrc
```
