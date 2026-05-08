# tmux Guide

A learning-oriented walkthrough of this tmux config. The shorter cheat-sheet style reference lives at `docs/README.md`; this file is the long-form companion that explains **why** the bindings look the way they do and **when** you would actually reach for them.

- **Config file:** `~/.config/tmux/tmux.conf` — symlinked to this repo at `tmux/tmux.conf`. Editing either is the same file.
- **Prefix:** `Ctrl+Space`. Whenever you read `prefix + X` below, press `Ctrl+Space` and let go before pressing `X`.
- **Theme:** Tokyo Night Storm, baked into `tmux.conf` (no external theme plugin).
- **Plugin manager:** TPM, auto-bootstrapped on first launch.

---

## 1. The mental model

Most of tmux clicks once you have these three nesting levels straight:

```
server
└── session                ← think: a project, or one logical context
    └── window             ← think: a tab inside that project
        └── pane           ← think: one terminal split inside the tab
```

- **One tmux server** runs in the background per user. `tmux ls` talks to it. Killing the server (`tmux kill-server`) ends every session at once.
- **Sessions** survive client disconnect. SSH drops, laptop closes — sessions keep running. You re-attach later with `tmux attach`.
- **Windows** are tabs. Each one has its own layout of panes.
- **Panes** are individual terminals. Each runs its own shell or program.

A useful default mental rule: **one session per project**, **one window per concern within that project** (editor, server, db shell, logs…), **panes for things you watch side-by-side** (editor + test runner).

---

## 2. Fresh machine setup

```sh
# 1. Clone and link
git clone <your-dotfiles-repo> ~/github/dotfiles
ln -s ~/github/dotfiles/tmux ~/.config/tmux

# 2. Start tmux. TPM clones itself on first start (see the bootstrap block at
#    the bottom of tmux.conf).
tmux

# 3. Install plugins
prefix + I       # capital I — installs everything declared in tmux.conf
```

After that, sessions auto-save every 15 minutes (tmux-continuum) and auto-restore the next time the tmux server starts.

---

## 3. The prefix key

The default tmux prefix is `Ctrl+B`, which is awkward (B is far from your home row, and conflicts with the `back-one-character` binding in many shells/editors). This config uses **`Ctrl+Space`** — both keys are under your thumb and pinky, easy to chord.

| Key | Action |
|---|---|
| `Ctrl+Space` | Activate prefix; status badge turns red and shows `PREFIX`. |
| `prefix + Ctrl+Space` | Send a literal `Ctrl+Space` through to the program (useful for nested tmux). |
| `prefix + ,` | Reload `tmux.conf` live — no restart. |
| `prefix + ?` | List every active binding (great for discovery). |
| `prefix + t` | Show a fullscreen clock (any key dismisses). |

> **Heads-up — zsh autosuggestions:** zsh defaults bind `Ctrl+Space` to `autosuggest-accept`, which becomes unreachable inside tmux because tmux grabs `Ctrl+Space` first. Use **`Ctrl+F`** for autosuggest-accept (set up in `zsh/conf.d/01-environment.zsh`). Outside tmux, `Ctrl+Space` still works.

---

## 4. Sessions

Sessions are the layer most people under-use. Treating each project as its own session means you can context-switch between work without ever closing anything.

### Bindings

| Key | Action |
|---|---|
| `prefix + s` | Open the session/window picker (built-in `choose-tree -Zs`). |
| `prefix + O` | sessionx — fzf-powered picker with previews, fuzzy search. |
| `prefix + N` | Create a new session, **prompts for a name**, inherits cwd. |
| `prefix + S` | Rename current session (prefilled with current name). |
| `prefix + X` | Kill current session (confirms first). |
| `prefix + d` | Detach from the session. Server keeps running. |
| `Alt+Up` / `Alt+Down` | Cycle through sessions without using prefix. |

### Use cases

- **"I want to switch to a different project for 5 minutes."**
  `prefix + O`, fuzzy-type the project name, hit Enter. Old session keeps running.

- **"I'm starting a new project."**
  In an existing pane, `cd ~/code/newproject` then `prefix + N`, type the session name, Enter. New session opens already in that directory.

- **"I have 4 SSH sessions to different boxes."**
  Each one is its own tmux session. `Alt+Up` / `Alt+Down` flips between them without breaking your hand.

- **"I want to clean up old sessions."**
  `prefix + s` (tree view) → navigate to the session → press `x` to kill it. The picker stays open for the next one.

> **Why `detach-on-destroy off`:** If you kill the session you're currently in, tmux switches you to the next available session instead of dropping you back to a bare shell. So you never accidentally close every session by killing one.

---

## 5. Windows

Windows are tabs within a session. Use one window per concern: editor, server, logs, database shell, scratch.

### Bindings

| Key | Action |
|---|---|
| `prefix + c` | New window, **inherits cwd**, auto-named after the running command. |
| `prefix + C` | New window, **prompts for a name**. Use this when you want "build", "logs", "db" etc. instead of "1:zsh". |
| `prefix + r` | Rename current window (prefilled). |
| `prefix + Tab` | Toggle between current and last window. *(Note: extrakto plugin claims this — see §13.7.)* |
| `prefix + n` / `prefix + p` | Next / previous window (repeatable — `-r` keeps the binding active). |
| `Alt+1` … `Alt+9` | Jump directly to window 1–9 (no prefix). |
| `prefix + b` | Break current pane out into its own new window. |
| `prefix + B` | Pull a pane from another window into this one as a vertical split. |

### Use cases

- **"I need to run a quick command in this directory."**
  `prefix + c` — new window in the same cwd. Run command, switch back with `prefix + Tab`.

- **"I want a labeled 'build' window."**
  `prefix + C`, type `build`, Enter. The status bar now shows `build` instead of `1:zsh`.

- **"I have 7 windows and I keep losing track."**
  Rename the important ones (`prefix + r`) and use `Alt+1..9` to jump. The status bar shows which window is active (blue background) vs has unread output (yellow underline).

- **"This pane really should be a window of its own."**
  Move into the pane, then `prefix + b`. It pops out into a new window keeping its history.

> **Why `base-index 1` and `pane-base-index 1`:** Windows and panes start counting from 1, so the digit on the keyboard matches the window number. `Alt+1` → window 1 instead of `Alt+2` → window 1.

> **Why `renumber-windows on`:** When you close window 2 of `[1, 2, 3]`, tmux renumbers to `[1, 2]`. So `Alt+2` always works on the second window without gaps.

---

## 6. Panes — splitting and moving around

### Splits

| Key | Action |
|---|---|
| `prefix + \|` | Split vertically (panes side by side). |
| `prefix + \\` | Same — alias for `\|` so you don't need Shift. |
| `prefix + -` | Split horizontally (panes stacked). |

All splits inherit the current pane's working directory, so a `git status` you ran in pane 1 still sees the right repo from pane 2.

### Navigation — vim-tmux-navigator

These bindings are **no-prefix** so they're as fast as moving between Neovim splits. The vim-tmux-navigator plugin makes the same Ctrl+h/j/k/l keys move between **tmux panes** *and* **Neovim splits** seamlessly:

| Key | Action |
|---|---|
| `Ctrl+h` | Move left (Neovim split or tmux pane). |
| `Ctrl+j` | Move down. |
| `Ctrl+k` | Move up. |
| `Ctrl+l` | Move right. |
| `prefix + ;` | Jump to last-active pane (toggle between two panes). |

The plugin checks whether the focused pane is running Neovim. If yes, the keypress is forwarded to Neovim's split navigation. Otherwise, tmux selects the next pane in that direction. From your perspective: you don't need to know whether you're crossing a Neovim split or a tmux pane border — the keys "just work."

> **Required Neovim side:** Install `christoomey/vim-tmux-navigator` in Neovim too. Without it, Ctrl+h/j/k/l from inside Neovim won't escape to tmux.

### Resizing

| Key | Action |
|---|---|
| `prefix + H` | Push the border left (5 cells). |
| `prefix + J` | Push it down. |
| `prefix + K` | Push it up. |
| `prefix + L` | Push it right. |

These are repeatable (`-r`) — within `repeat-time 600`ms you can keep pressing `H` without re-pressing prefix.

### Swap and follow

| Key | Action |
|---|---|
| `prefix + <` | Swap with previous pane *and follow*. |
| `prefix + >` | Swap with next pane *and follow*. |

The "follow" half (`select-pane -L/-R` after the swap) means the cursor sticks with the pane you just moved. So `prefix + > > >` walks **your** pane to the right through the layout — instead of shuffling other panes past a stationary cursor.

### Layout helpers (defaults — no rebinds)

| Key | Action |
|---|---|
| `prefix + Space` | Cycle through built-in layouts (even-h, even-v, main-h, main-v, tiled). *(Note: tmux-thumbs claims this — see §13.6.)* |
| `prefix + z` | Toggle zoom on the current pane (full-window, then back). |
| `prefix + q` | Briefly show pane numbers; type a number to jump to that pane. |
| `prefix + !` | Break current pane to a new window (default; same as `prefix + b` here). |
| `prefix + {` / `prefix + }` | Move current pane left / right in the index order. |

---

## 7. Pane management

### Kill, clear, mark

| Key | Action |
|---|---|
| `prefix + x` | Kill current pane immediately (no confirmation). |
| `prefix + Ctrl+l` | Send `Ctrl+L` to the shell *and* wipe the tmux scrollback. |
| `prefix + m` | Mark current pane (referenced as `~` by `join-pane` / `swap-pane`). |
| `prefix + M` | Clear pane mark. |
| `prefix + e` | Respawn the pane's command (used after `remain-on-exit failed` keeps a crashed pane open for inspection). |

### Use cases

- **"I want to paste this terminal output to a coworker without my recent commands trailing along."**
  `prefix + Ctrl+l` first. The visible screen *and* the scrollback are both gone, so a `tmux capture-pane -p` (or just selecting in copy mode) starts from zero.

- **"I want to pull a pane from window 5 into this window."**
  Go to the pane in window 5, `prefix + m` to mark it. Come back to your current window. `prefix + :` to enter command mode, type `join-pane -s ~`, Enter. The marked pane lands here.

- **"My dev server crashed and I want to see the error before restarting."**
  `remain-on-exit failed` (set globally) keeps the pane open with the dead output visible. Read the stack trace, then `prefix + e` to respawn the same command.

- **"I made `prefix + x` non-confirming. What if I press it by accident?"**
  `prefix + x` requires a multi-key sequence — accidental fat-fingers are extremely rare. The trade is one wasted keystroke per intentional kill (instead of two).

### Sync panes — running the same command on N hosts

| Key | Action |
|---|---|
| `prefix + P` | Toggle synchronize-panes for the current window. Status badge shows purple `SYNC` when it's on. |

Use case: split into 4 panes, SSH into 4 different boxes (one per pane), enable sync, run `apt update && apt upgrade` once — it executes in all 4. Toggle off the moment you need to interact with one box only.

> **Sanity badge:** Without the `SYNC` indicator in the status bar, it's far too easy to forget sync is on and accidentally run a destructive command across every host.

### Pipe-pane logging — capture output to a file

| Key | Action |
|---|---|
| `prefix + *` | Toggle logging the current pane to a file. |

The log goes to `~/.local/state/tmux/<session>-<window>-<pane>.log` (XDG state dir; auto-created on first use). Filenames use indexes — not the window's display name — so spaces or slashes in window names can't break the path or trigger shell injection.

Use case: long-running test or build, you want to keep the output even after the pane scrolls past it. Toggle logging on, run the command, toggle off when done.

---

## 8. Copy mode (vi)

Copy mode is tmux's version of "scroll up to look at history and grab some text." Bindings here mirror vim's visual mode.

### Entering and exiting

| Key | Action |
|---|---|
| `prefix + v` | Enter copy mode (mnemonic: visual). |
| `prefix + [` | Same — tmux default. |
| `q` or `Escape` | Exit copy mode. |

The status bar shows yellow `COPY` while you're in this mode.

### Movement

| Key | Action |
|---|---|
| `h j k l` | Character motions. |
| `w` / `b` | Word forward / back. |
| `0` / `$` | Start / end of line. |
| `Ctrl+u` / `Ctrl+d` | Half-page up / down. |
| `g` | Top of scrollback. |
| `G` | Bottom of scrollback. |

### Search

| Key | Action |
|---|---|
| `/` | Search forward (incremental — matches highlight as you type). |
| `?` | Search backward (incremental). |
| `n` | Next match. |
| `N` | Previous match. |

`set -g wrap-search off` mirrors vim's `nowrapscan` — searches stop at the end of scrollback instead of jumping back to the top, which avoids the disorienting "wait, where am I now?" feeling.

### Selection and yank

| Key | Action |
|---|---|
| `v` | Begin character selection. |
| `Ctrl+v` | Toggle rectangle / block selection. |
| `y` | Yank to system clipboard, exit copy mode. |
| `Enter` | Same as `y`. |
| Mouse drag | Select; auto-yank on release. |

Yank goes to the **system clipboard** via tmux-yank (see §13.3). Paste outside tmux with `Cmd+V` / `Ctrl+V` or wherever your OS puts pasted text.

### Use cases

- **"I want to grep through the last hour of build output."**
  `prefix + v`, `?stack trace` (search backward), step through with `n`/`N`, `v` to start selecting at the line you want, motion keys to extend, `y` to copy, paste it into chat.

- **"I want a column of values out of `kubectl get pods` output."**
  `prefix + v`, position cursor, `Ctrl+v` to switch to block mode, drag the rectangle, `y`. Block selection is the trick people forget exists.

---

## 9. Popup terminal (scratch session)

| Key | Action |
|---|---|
| `prefix + g` | Open a floating popup (80% × 80%) attached to a persistent `scratch` session, in the current pane's cwd. |

The popup overlays your current layout — no panes are split, no windows are created. Type `exit` (or kill the shell) to close it.

Use cases:

- **Quick `git status`** without splitting your editor pane.
- **Looking up a path** without losing your current command line.
- **A persistent scratch shell** — because the popup attaches to a named session (`scratch`), every time you open it you're back in the same shell with its history. It survives across reboots if continuum is restoring sessions.

---

## 10. Plugins

All plugins are managed by TPM. They live in `~/.config/tmux/plugins/`, declared in the PLUGINS section of `tmux.conf`.

| Key | Action |
|---|---|
| `prefix + I` | Install plugins listed in `tmux.conf`. |
| `prefix + U` | Update installed plugins. |
| `prefix + Alt+u` | Uninstall plugins removed from `tmux.conf`. |

> **Removing a plugin from the config doesn't delete its files.** You must press `prefix + Alt+u` to physically remove `~/.config/tmux/plugins/<plugin>/`. Until then, declarations like `set -g @plugin '...'` can be uncommented to bring the plugin back instantly.

### 10.1 tmux-resurrect — manual save/restore

| Key | Action |
|---|---|
| `prefix + Ctrl+s` | Save current sessions/windows/panes to disk. |
| `prefix + Ctrl+r` | Restore the most recent save. |

Configured to also capture pane contents (`@resurrect-capture-pane-contents on`) and to restart these long-running interactive programs after restore: `ssh nvim vim vi htop btop k9s less more man tail watch`.

> **Privacy note:** Captured pane contents can include any text that scrolled across the pane — including secrets you typed at a prompt. If you ever paste credentials, wipe `~/.local/share/tmux/resurrect/` to clear the saved snapshots.

### 10.2 tmux-continuum — auto-save/restore

Builds on resurrect. Saves automatically every 15 minutes (`@continuum-save-interval '15'`), restores on tmux server start (`@continuum-restore on`).

You won't see any UI for this — it just works. To verify it's saving, look at the timestamps in `~/.local/share/tmux/resurrect/`.

### 10.3 tmux-yank — system clipboard

No bindings; works behind the scenes. When you `y` in copy mode, the selection lands in your system clipboard via auto-detected backend (`pbcopy` on macOS, `xclip`/`xsel`/`wl-copy` on Linux). Configured to use the *clipboard* (not the X selection): `@yank_selection 'clipboard'`.

### 10.4 vim-tmux-navigator — Ctrl+h/j/k/l between panes and Neovim

See §6 for the user-facing bindings. The matching Neovim plugin must also be installed for the navigation to work *out of* a Neovim window.

> **Caveat:** This plugin re-binds `prefix + Ctrl+l` to a plain `send-keys C-l` after your config loads. We override that with `set -g @vim_navigator_prefix_mapping_clear_screen ''` so our `clear+history` binding wins.

### 10.5 tmux-open — open URL/path from copy mode

While in copy mode with the cursor over a path or URL:

| Key | Action |
|---|---|
| `o` | Open in default app (`open` macOS / `xdg-open` Linux). |
| `Ctrl+o` | Open in `$EDITOR`. |

### 10.6 tmux-fzf-url — fzf URL picker

| Key | Action |
|---|---|
| `prefix + u` | Fuzzy-pick any URL visible in the current pane and open it. |

Requires `fzf` installed (`brew install fzf` / package manager).

### 10.7 tmux-thumbs — vimium-style hint mode

| Key | Action |
|---|---|
| `prefix + Space` | Show two-letter hints over every path / hash / URL / IP visible in the pane. Type the two letters to copy. |
| `prefix + Shift+Space` | Same, but also `open`s the match. |

> **Conflict:** `prefix + Space` defaults to `next-layout` in tmux. The plugin overrides it. If you want the layout cycler back, change `@thumbs-key` to a different letter.

> **First-run:** thumbs ships as a Rust binary. On first use it can compile via cargo, which takes a minute. Pre-install with `brew install tmux-thumbs` to skip this.

### 10.8 extrakto — fzf over visible text

| Key | Action |
|---|---|
| `prefix + Tab` | Open fzf over everything visible in the pane (words, paths, URLs, git hashes, quoted strings). Picks land on the clipboard or get inserted at the prompt. |

> **Conflict:** `prefix + Tab` is `last-window` in our config, but extrakto loads after `bind Tab last-window` and wins. To get last-window back, set `@extrakto_key` to something else (e.g. `e`).

### 10.9 tmux-sessionx — fzf session picker

| Key | Action |
|---|---|
| `prefix + O` | Open the sessionx fuzzy picker over your sessions, with window-content previews. |

Faster than `prefix + s` (built-in choose-tree) when you have many sessions. Supports creating sessions inline.

---

## 11. Status bar reference

Status bar lives at the **top** of the screen.

```
   myproject     1 nvim   2 build   3 logs   4 ssh-prod                     ZOOM SYNC
 └─ status-left  └─ window list (active in blue, activity yellow,            └─ status-right
    (session)        bell red)                                                  (state badges)
```

### Indicators in `status-right`

| Badge | Meaning |
|---|---|
| `PREFIX` (red) | You just pressed `Ctrl+Space`; tmux is waiting for your next key. |
| `COPY` (yellow) | You're in copy mode. |
| `ZOOM` (green) | The active pane is zoomed (filling the window). |
| `SYNC` (purple) | `synchronize-panes` is on — every keystroke broadcasts to all panes in this window. |

The right side is **empty** when none of the above are active — by design. There's no clock, no battery, no CPU widget, because the OS already shows time and the goal is to keep the bar quiet. `status-interval` is set to 60s since nothing here actually needs frequent re-rendering — tmux re-draws the badges instantly on the relevant event.

### Pane border title

Each pane's top border shows:
```
 1 nvim       2 zsh       3 git
```
- Number = pane index — used with `prefix + q` to jump.
- Name = the command currently running in that pane.

### Window list flags (default tmux indicators)

If you ever turn on `#F` in the format string, these are what you'd see:

| Flag | Meaning |
|---|---|
| `*` | Current window (active). |
| `-` | Last visited window. |
| `Z` | Active pane is zoomed. |
| `!` | Bell rang. |
| `~` | Silence alert (if monitor-silence is on). |

---

## 12. Workflows

### Starting a new project

```sh
cd ~/code/widget-service
tmux                        # if not already in tmux
prefix + N                  # type "widget", Enter — new session named widget in cwd
prefix + |                  # vertical split
nvim .                      # editor in left pane
Ctrl+l                      # move to right pane (vim-tmux-navigator)
npm run dev                 # dev server in right pane
prefix + C                  # type "logs" — new named window
docker compose logs -f
prefix + Tab                # back to editor window  (or extrakto-overridden — use Alt+1)
```

### Switching projects mid-thought

```
prefix + d                  # detach current session — everything keeps running
tmux attach -t otherproject # or: prefix + O, fuzzy-pick the other session
# do other thing
prefix + d
tmux attach -t widget       # back to widget exactly where you left off
```

### Recovering after a reboot

```
tmux                        # continuum auto-restores
# If the auto-restore didn't fire (rare):
prefix + Ctrl+r             # manual resurrect restore
```

### Debugging across N machines simultaneously

```
prefix + N                  # name it "rollout"
prefix + |                  # split vert
prefix + |                  # split again
prefix + -                  # split horizontal in last pane
# Now 4 panes. SSH into a different host in each:
ssh box1     ssh box3
ssh box2     ssh box4
prefix + P                  # SYNC ON — status bar shows purple SYNC
sudo systemctl restart api  # runs on all 4
prefix + P                  # SYNC OFF before any per-host work
```

### Reading a long log

```
# In the pane running `tail -f`:
prefix + v                  # enter copy mode
?error                      # search backward
n n n                       # walk through matches
v                           # start selecting at the interesting line
} } }                       # paragraph motions
y                           # copy to system clipboard
```

### Quick lookup without losing layout

```
prefix + g                  # popup scratch session
ls -la some/path
exit                        # popup closes; you're back exactly where you were
```

---

## 13. Configuration deep-dive

A short tour of the more interesting options in `tmux.conf` — useful when you want to tweak something and need to know which knob to turn.

### 13.1 Terminal capabilities

```
set -g default-terminal "tmux-256color"
set -as terminal-features ",*:RGB"
set -as terminal-features ",*:usstyle"
```

- `default-terminal "tmux-256color"` advertises 256-color support to programs running *inside* tmux.
- `terminal-features RGB` tells tmux that the **outer** terminal (Ghostty, iTerm2, kitty) supports 24-bit color sequences. Without this, Tokyo Night's blues turn into approximated muddy 256-colors.
- `terminal-features usstyle` enables curly/dotted/dashed underlines (Neovim LSP diagnostics use these).

### 13.2 Latency-sensitive options

```
set -sg escape-time 10
set -g focus-events on
set -g repeat-time 600
```

- `escape-time 10` (ms) is how long tmux waits after Escape to see if it's part of a longer key sequence. Default 500 ms makes Neovim's mode-switching feel sluggish.
- `focus-events on` forwards focus-in/-out to programs inside tmux, so Neovim's autoread and dim-on-blur work.
- `repeat-time 600` (ms) is the window in which `-r` bindings (resize, swap, next/prev window) accept repeats without re-pressing prefix.

### 13.3 Clipboard and passthrough

```
set -s set-clipboard on
set -g allow-passthrough on
```

- `set-clipboard on` enables OSC 52 passthrough: programs inside tmux can write the system clipboard directly via terminal escape sequences, without going through tmux-yank.
- `allow-passthrough on` (active pane only, **not** `all`) lets inline image protocols (kitty/Ghostty) and image.nvim send their bytes through tmux. Limiting to active-pane-only reduces the surface area for escape-sequence injection from a remote SSH host.

### 13.4 Window sizing

```
set -g window-size largest
```

Sizes each window to the **largest** client currently viewing it. So if you're attached from both a small laptop and a big external monitor, windows fit the big monitor and the laptop sees truncated output (instead of every window shrinking to the laptop's size).

### 13.5 Activity monitoring

```
setw -g monitor-activity on
set -g visual-activity off
```

Background windows that produce output get the activity highlight (yellow) in the status bar. The `visual-activity off` suppresses the noisy `Activity in window X` message that pops up otherwise.

### 13.6 Indexing

```
set -g base-index 1
set -g pane-base-index 1
set -g renumber-windows on
```

Windows and panes start at 1 so `Alt+1` lands on the first window, not the second. Renumber-on-close keeps gaps from forming.

### 13.7 Plugin paths

```
set-environment -g TMUX_PLUGIN_MANAGER_PATH "$HOME/.config/tmux/plugins"
```

Required because TPM looks here. Note the `$HOME` (not `~`) — single-quoted `~` doesn't expand in tmux config strings.

### 13.8 TPM bootstrap

```
if "test ! -d $HOME/.config/tmux/plugins/tpm" \
   "run 'git clone --depth=1 https://github.com/tmux-plugins/tpm $HOME/.config/tmux/plugins/tpm \
   && $HOME/.config/tmux/plugins/tpm/bin/install_plugins'"

run "$HOME/.config/tmux/plugins/tpm/tpm"
```

The `if` block clones TPM if it isn't there yet *and* runs `install_plugins` — so a fresh machine gets a fully-equipped tmux on first start, no manual steps. The `run` line below initializes TPM so plugin bindings are loaded. Both must stay at the bottom of `tmux.conf`.

---

## 14. Troubleshooting

**`prefix + I` does nothing — plugins don't install.**
Confirm TPM exists:
```sh
ls ~/.config/tmux/plugins/tpm
```
If it doesn't, the bootstrap line at the bottom of `tmux.conf` was probably skipped (e.g. `git` wasn't on `$PATH`). Clone it manually:
```sh
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
```
Then `prefix + ,` to reload, `prefix + I` to install.

**Colors look washed out in Neovim.**
Verify RGB capability is reaching tmux:
```sh
tmux info | grep -i rgb
```
Expect `RGB: (flag) true`. If not, your outer terminal probably doesn't advertise 24-bit color — check Ghostty/iTerm2 settings or `$TERM` outside tmux.

**Clipboard not working.**
On macOS Ghostty + tmux-yank works out of the box. On Linux, install one of `xclip`, `xsel`, `wl-clipboard` (Wayland) — tmux-yank auto-detects.

If you're on an old macOS where clipboard is broken inside tmux, install `reattach-to-user-namespace` and uncomment the `if-shell "uname | grep -q Darwin"` block near the bottom of `tmux.conf`.

**`Ctrl+Space` doesn't reach tmux.**
Some terminals swallow it. Test outside tmux: `cat`, then press `Ctrl+Space` — you should see `^@` echoed. If nothing appears, your terminal is intercepting the key. Either re-bind Ghostty/etc. to pass it through, or switch the prefix to `C-a` in `tmux.conf` (~line 44).

**`prefix + u` (URL picker) does nothing.**
Install `fzf`. The plugin requires it.

**Inline images don't render (Ghostty).**
Confirm `allow-passthrough on` in your config (it is). Confirm Ghostty itself is configured for the kitty image protocol. Confirm tmux is 3.3+: `tmux -V`.

**Sessions don't restore on tmux start.**
Trigger a save first:
```
prefix + Ctrl+s
```
Then check `~/.local/share/tmux/resurrect/` — the latest file should be non-empty. Auto-restore reads the latest file each time the server starts.

**`prefix + Tab` doesn't go to last-window — it opens fzf.**
That's extrakto. If you'd rather have last-window back, set `@extrakto_key 'e'` (or any other free key) in `tmux.conf`.

**The popup `prefix + g` is empty / errors out.**
The popup attaches to a session named `scratch`. If a process already holds that session in a weird state, kill it from `prefix + s`, then try again — the next `prefix + g` will recreate it.

---

## 15. Where to look when…

- **You want to change a binding.** `tmux.conf` — KEY BINDINGS section (~line 140).
- **You want a different theme.** STATUS BAR section (~line 338). Hex codes are inline.
- **You want a different prefix.** Top of `tmux.conf` (~line 44).
- **You want longer scrollback.** `history-limit` (~line 76). 50000 lines by default.
- **You want to disable a plugin.** Comment out its `set -g @plugin '...'` line. Then `prefix + ,` to reload, `prefix + Alt+u` to uninstall.
- **You want to add a plugin.** Add its `set -g @plugin 'org/plugin'` line above the TPM bootstrap block. Reload, `prefix + I` to install.
