# zsh config

A fast, pragmatic, **modular** zsh setup — no plugin manager, sensible defaults,
macOS-first with graceful Linux/WSL degradation.

This is the merge of two lineages:

- the previous **single-file zsh config** (cross-platform, batteries included) — the base;
- the **Omarchy bash config**'s unique gems (`sff`, `tds`, `ic`/`ix`/`icx`, `gcad`,
  `try` integration, the `~/.local/bin/env` toolchain shim), ported to zsh and
  made macOS-portable. (Omarchy's kitty-only `icat` image previews in `ff` were
  dropped — this setup targets Alacritty/Ghostty, where that branch never fires.)

See [REFERENCE.md](REFERENCE.md) for the full cheatsheet of every alias, function,
and keybinding.

## Layout

```
zsh/
  .zshrc              # thin loader — resolves its own real path, sources conf.d/
  .zprofile           # login-shell hook (toolchain env shim)
  conf.d/
    00-os.zsh         # _os detection (macos / linux / wsl / other)
    10-env.zsh        # locale, EDITOR, XDG, pager/bat, LS_COLORS, PATH, env shim
    20-options.zsh    # setopt, history, WORDCHARS, REPORTTIME
    30-completion.zsh # fpath, compinit (24h cache + zcompile), zstyles
    40-keybindings.zsh# emacs mode, smart Tab, word nav, quoting widgets
    50-fzf.zsh        # fzf env + integration; ff/eff/sff, fcd/fkill/fhist/fenv/fman
    55-plugins.zsh    # autosuggestions → syntax-highlighting → hist-substring-search
    60-prompt.zsh     # starship (vcs_info fallback)
    65-aliases.zsh    # nav, listing, viewing, tool swaps, safety, config, network
    70-git.zsh        # git aliases (incl. gcad) + gbr/gshow/groot/gignore + worktrees
    72-dev.zsh        # docker, npm, python, rails, AI CLIs (c / cx)
    74-tmux.zsh       # session aliases + tdl/tds/tdlm/tsl layouts + ic/ix/icx
    76-functions.zsh  # mkcd, extract, up, serve, json, dotenv, fip/dip/lip, …
    78-media.zsh      # ffmpeg / imagemagick transcode helpers
    80-linux.zsh      # Linux only: open() wrapper, localip, iso2sd, format-drive
    82-macos.zsh      # macOS only: brewup, hidden/ql/notify, APFS case-fix hook
    88-hooks.zsh      # terminal title on cd
    90-tools.zsh      # direnv, mise, thefuck, atuin, try — zoxide LAST
  README.md           # this file
  REFERENCE.md        # cheatsheet
```

The loader resolves its own location through symlinks
(`${${(%):-%N}:A:h}`), so `~/.zshrc` can be a symlink into this repo. Modules
load in filename order; the numeric prefixes **are** the dependency graph.
Platform modules gate themselves with `[[ $_os == … ]] || return 0` — a
top-level `return` in a sourced file just stops that file.

At the very end, `~/.zshrc.local` is sourced if present — put machine-specific
overrides there, not in the repo.

## Install (macOS)

```sh
cd ~/GITHUB/dotfiles
# repo convention: back up, then symlink
[ -f ~/.zshrc ]    && mv ~/.zshrc    ~/.zshrc.backup-$(date -u +%Y%m%dT%H%M%SZ)
[ -f ~/.zprofile ] && mv ~/.zprofile ~/.zprofile.backup-$(date -u +%Y%m%dT%H%M%SZ)
ln -s ~/GITHUB/dotfiles/zsh/.zshrc    ~/.zshrc
ln -s ~/GITHUB/dotfiles/zsh/.zprofile ~/.zprofile
exec zsh
```

Required tools:

```sh
brew install zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search \
             starship fzf fd bat eza ripgrep zoxide direnv
```

Optional — every one is detected and degrades gracefully:
`mise` `lazygit` `btop` `dust` `procs` `delta` `duf` `tldr` `thefuck` `atuin`
`gum` (needed by `gwd`) `jq` `ffmpeg` `imagemagick` `try` `zsh-completions`.

## Ordering invariants

Enforced by the numeric module prefixes. Don't renumber casually.

| Constraint | Where | Why |
|---|---|---|
| `_os` set first | `00` | Every `[[ $_os == … ]]` branch depends on it. |
| `XDG_CACHE_HOME` before compinit | `10` → `30` | compinit writes its dump to `$XDG_CACHE_HOME/zsh/`. |
| `fpath` before `compinit` | `30` (top → bottom) | Completions are scanned at compinit time. |
| `bindkey '^I'` before fzf loads | `40` → `50` | fzf saves the previous Tab binding as `fzf_default_completion` — that's how `cd **<Tab>` works while plain Tab hits the smart widget. |
| autosuggestions → syntax-highlighting → history-substring-search | `55` | hist-substring-search must be sourced last (its own docs). |
| `_bind_history_search` defined before it's called | `40` → `55` | The widgets it binds only exist after the plugin sources. |
| APFS case hook before title hook | `82` → `88` | The title should show the canonical PWD. |
| Tool evals last, **zoxide very last** | `90` | They override builtins (`cd`) and need final PATH/EDITOR. zoxide's doctor warns if any hook registers after it — this ordering keeps it silent. |

## Design notes

- **`ff` is a function, not an alias** (it was an alias before). Functions
  resolve at call time — so `sff`/`eff` can call it safely — and it picks its
  preview at runtime: `bat` if installed, else `cat`.
- **`sff`** (fuzzy-pick newest file, `scp` it somewhere) was written for GNU
  `find -printf`, which doesn't exist on macOS. The port uses zsh glob
  qualifiers instead: `**/*(.Nom)` — plain files, newest first.
- **Never name a local `path`** — zsh ties `path`↔`PATH`; a `local path=…`
  clobbers command lookup inside the function. This bit the old `gwa` (fixed:
  `wt_path`, matching Omarchy's original naming).
- **`BAT_THEME`** uses `tokyonight_night` only when the theme file exists *and*
  `bat cache --build` has been run; otherwise `ansi` (built-in, Omarchy's
  choice) — avoids bat's "Unknown theme" warning on every invocation.
- **History**: `share_history` on, `inc_append_history` intentionally off
  (enabling both duplicates entries). Prefix a command with a space to keep it
  out of history.
- **`^Q`** is `push-line-or-edit`; `stty -ixon` frees it from flow control.
- **APFS case-fix**: macOS is case-insensitive/case-preserving, so `cd github`
  leaves `$PWD` as you typed it. The `82` chpwd hook rewrites `$PWD` to the
  on-disk casing; symlinks are deliberately not resolved.
- **delta is a pager**, not a `diff(1)` replacement — use `deltadiff` (wraps
  `diff -u | delta`); `diff` itself is untouched.

## Naming decisions where the two lineages collided

| Name | Omarchy bash meant | Here it means | The Omarchy behavior lives at |
|---|---|---|---|
| `d` | `docker` | `dirs -v` | `dk` |
| `t` | `tmux attach \|\| new Work` | `tmux ls` | `tw` |
| `ga` / `gd` | worktree add / drop | `git add` / `git diff` | `gwa` / `gwd` |
| `gcam` | `git commit -a -m` | `git commit --amend` | `gcm` + `gaa`, or `gcad` for amend -a |
| `ls` | `eza -lh` (long) | `eza` (short) | `ll` (and `lsa` = long + all) |

## Reload after edits

```sh
reload      # alias: source ~/.zshrc
exec zsh    # cleaner — fresh shell
```

## Troubleshooting

- **Slow startup?** `zsh -ixc : 2>&1 | ts -i '%.s' | tail -50`. Usual culprits:
  compinit rebuild (delete `~/.cache/zsh/zcompdump*`) or a slow `mise activate`.
- **`compinit: insecure directories`?** `compaudit | xargs chmod g-w,o-w`.
- **fzf `**` trigger dead?** `bindkey '^I'` must show `fzf-completion` and
  `$fzf_default_completion` must be `_tab_complete_smart`. If not, something
  rebound Tab after module 50 loaded.
- **zoxide doctor warning?** Something registered a precmd/chpwd hook after
  module 90. Keep zoxide's init as the last hook-registering line.
