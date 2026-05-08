# zsh config

A fast, pragmatic zsh setup — single-file, no plugin manager, sensible defaults.

- **`.zshrc`** — the entire interactive shell config in one flat file.
- **`.zprofile`** — login-shell hook (currently empty; reserved).
- **`REFERENCE.md`** — cheatsheet listing every alias, function, keybinding, option, and tool integration.
- **`README.md`** — this file. Install, structure, design notes.

## Install

The `.zshrc` lives in this repo and is symlinked into `$HOME`:

```sh
ln -sf "$PWD/zsh/.zshrc"    "$HOME/.zshrc"
ln -sf "$PWD/zsh/.zprofile" "$HOME/.zprofile"
```

Required tools (Homebrew on macOS, pacman/apt on Linux):

```sh
brew install \
  zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search \
  zsh-completions \
  starship fzf fd bat eza ripgrep zoxide direnv mise
```

Optional (the config detects each one and degrades gracefully):
`lazygit` `btop` `dust` `procs` `delta` `duf` `tldr` `thefuck` `atuin` `gum` `jq`.

## Structure of `.zshrc`

The file is organized as a top-to-bottom load with no helper layer. Sections in order:

1. **OS detection** (`_os` = `macos` / `linux` / `wsl` / `other`)
2. **Environment** (locale, `EDITOR`, XDG dirs, pager, `LS_COLORS`, `PATH`)
3. **Shell options** (`setopt`, history config, `WORDCHARS`, `REPORTTIME`)
4. **Completion** (fpath, `compinit` with 24h cache, zstyle rules)
5. **Keybindings** (emacs mode, smart Tab widget, word nav, history search hooks)
6. **fzf** (env vars, key-binding shell integration)
7. **Plugins** (autosuggestions → syntax-highlighting → history-substring-search)
8. **Prompt** (Starship, with vcs_info fallback)
9. **Aliases** (navigation, listing, git, docker, tmux, npm, python, network, macOS)
10. **Functions** (extract, fzf helpers, git helpers, tmux layouts, media, macOS)
11. **Tool integrations** (zoxide, direnv, mise, thefuck, atuin)
12. **Hooks** (macOS APFS path-case canonicalization, terminal title)

## Ordering invariants

These constraints are enforced by file order. Don't reorder casually — the config will silently break if you do.

| Constraint                                                                                                                                                                                       | Why                                                                                                              |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------- |
| `_os` set before anything else                                                                                                                                                                   | Every later branch (`[[ $_os == macos ]]`) depends on it.                                                        |
| `XDG_CACHE_HOME` set before `compinit`                                                                                                                                                           | `compinit` writes its dump to `$XDG_CACHE_HOME/zsh/zcompdump`.                                                   |
| `fpath` configured before `compinit`                                                                                                                                                             | Completion functions are scanned at `compinit` time. Adding to `fpath` afterwards has no effect.                 |
| `bindkey '^I' _tab_complete_smart` runs **before** fzf shell integration loads                                                                                                                   | fzf binds `^I` to its own widget on load and saves the previous binding as `fzf_default_completion`. That's how `cd **<Tab>` works AND plain Tab still hits the smart widget. Rebinding `^I` after fzf loads breaks the `**` trigger. |
| Plugin order: **autosuggestions → syntax-highlighting → history-substring-search**                                                                                                               | history-substring-search hooks ZLE widgets that syntax-highlighting wraps; reversing them produces broken highlights. history-substring-search must be sourced last (per its own README). |
| `_bind_history_search` is called **after** the history-substring-search plugin sources                                                                                                           | The widgets it binds (`history-substring-search-up/down`) only exist post-source.                                |
| Tool eval hooks (`zoxide`, `direnv`, `mise`, `thefuck`, `atuin`) run last                                                                                                                        | They override builtins (`cd`) and rely on `$PATH`, `$EDITOR`, etc., already being set.                           |
| `_fix_pwd_case` registered before `_set_terminal_title`                                                                                                                                          | Both are `chpwd` hooks. Title hook should see the canonicalised PWD, not the typed-in casing.                    |

## Design notes (the "why" behind subtle choices)

### History
- `share_history` is on, **`inc_append_history` is off**. They overlap — enabling both produces duplicate-looking entries and confusing ordering across concurrent shells.
- `hist_ignore_space` is on, so prefixing a command with a space keeps it out of history (useful for secrets).
- `HISTSIZE=SAVEHIST=200000` — generous.

### Completion
- Cached zcompdump rebuilt at most once per 24 hours, then `zcompile`d in the background for faster subsequent loads.
- `auto_menu` on, `menu_complete` **off**. The first form shows an interactive menu on second Tab; the second auto-inserts the first match and conflicts with `menu select`.
- `setopt correct` is on (suggests typo corrections for *commands*) but `correct_all` is off (would prompt for argument typos too — way too noisy).

### Keybindings
- Emacs mode (`bindkey -e`).
- `WORDCHARS` is stripped of `/`, `=`, `:` — Ctrl-W now stops at path components, env-var assignments, and URL boundaries instead of eating whole paths.
- `^F`, `^]`, `^Space` all accept the autosuggestion. `^F` is the primary one because tmux owns `^Space` and `^]` is awkward.
- `^Q` is rebound to `push-line-or-edit`. Most modern terminals don't use `^Q`/`^S` for flow control.

### FZF
- **Bind values that contain whitespace, pipes, or parens MUST be wrapped in single quotes** in the final `FZF_DEFAULT_OPTS` string. fzf parses that env var like a shell command line; an unquoted pipe gets word-split and fzf bails with `invalid command line string`. The clipboard-yank bind is built as a separate variable so the action body (`execute-silent(echo {+} | pbcopy)`) can be single-quoted without colliding with zsh's `${var:+...}` brace matching.
- The Tab widget is captured by fzf as `fzf_default_completion`, so `cd **<Tab>` triggers the fzf picker while plain Tab still hits the smart widget.

### Plugins (no plugin manager)
- The three plugins are sourced directly via a `_source_first` helper that tries Homebrew, Arch, and Debian paths in that order. No zinit/oh-my-zsh — fewer moving parts, faster startup.

### macOS path canonicalization
- APFS is case-insensitive but case-preserving. `cd github` succeeds when the directory is `GITHUB`, but `$PWD` then reflects what you typed (`/Users/mo/github`) rather than the on-disk name (`/Users/mo/GITHUB`). The `_fix_pwd_case` chpwd hook rewrites `$PWD` to the canonical casing component-by-component using a case-insensitive glob (`(#i)`). Symlinks are intentionally **not** resolved — `cd /tmp` still shows `/tmp`, not `/private/tmp`.

### Aliases worth flagging
- `pip='pip3'` — assumes Python 3. Inside a venv, both names are the same binary.
- `delta` is a **pager** for unified diff output, not a `diff(1)` replacement. Aliasing `diff` to `delta` would break `diff file1 file2`. Use `git diff` (which uses delta via `core.pager`) or pipe `diff -u | delta`.
- `rm`/`cp`/`mv` are aliased to `-iv` (interactive + verbose). To bypass any alias for a single call, prefix with a backslash: `\rm`, `\cp`.
- `myip` has `--max-time 5` so it doesn't hang when the network is down.

### What's intentionally NOT here
- No `inc_append_history` (covered by `share_history`).
- No `url-quote-magic` self-insert binding (causes typing lag, conflicts with bracketed-paste).
- No `^F`-binding for `thefuck` (that key belongs to autosuggest-accept).

## Reload after edits

```sh
reload         # alias for `source ~/.zshrc`
exec zsh       # cleaner — replaces the current shell with a fresh one
```

## Troubleshooting

- **Slow startup?** Run `zsh -ixc : 2>&1 | ts -i '%.s' | tail -50` to see where time is spent. Common culprits: `compinit` rebuild (delete `~/.cache/zsh/zcompdump*` and let it regenerate), or a slow `mise activate`.
- **`compinit: insecure directories`?** A directory in `fpath` is world-writable. `compaudit | xargs chmod g-w,o-w`.
- **fzf `**` trigger doesn't pop the picker?** Verify `bindkey "^I"` returns `fzf-completion` and `$fzf_default_completion` is `_tab_complete_smart`. If `^I` is bound directly to `_tab_complete_smart`, fzf integration loaded before the bindkey ran.
- **Ctrl-R shows the old reverse-i-search?** atuin's hook didn't load — install it or remove the eval line.
