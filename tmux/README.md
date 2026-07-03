# tmux

**tmux** ("terminal multiplexer") lets one terminal window hold many shells at
once, splits them into panes, groups them into windows (tabs) and sessions, and
— crucially — keeps them all running on the machine even after you close the
terminal or disconnect. You reconnect later with `tmux attach` and everything is
exactly where you left it.

- **Live path:** `~/.config/tmux/tmux.conf` → symlink → `tmux/tmux.conf` (this dir)
- **Editing the file here edits the live config.** Reload a running tmux with
  `prefix + q` (see below) or `tmux source-file ~/.config/tmux/tmux.conf`.
- **No plugins.** This is a deliberately minimal, plugin-free config — everything
  here is built-in tmux, so a fresh checkout works with zero install step.

## Mental model (read this first)

```
session  ── a named workspace that survives terminal close   (switch: P / N)
└─ window ── like a browser tab, full-screen                  (switch: Alt+←/→, Alt+1..9)
   └─ pane ── a split region inside a window                  (move: Ctrl+Alt+arrows)
```

Almost every tmux command starts with the **prefix** — a key you press *and
release*, then press the command key. Here the prefix is **`Ctrl+Space`** (with
**`Ctrl+b`** also accepted as a fallback). So "`prefix + q`" means: press
`Ctrl+Space`, let go, then press `q`.

## Quick start

| You want to… | Keys |
|---|---|
| Start tmux | type `tmux` (new session) or `tmux attach` (reattach) |
| Split right / down | `prefix + \|` / `prefix + -` |
| Split (prefix-free) | `Alt+Enter` = top/bottom · `Alt+Shift+Enter` = side/side |
| Move between panes | `Ctrl+Alt+←/↑/↓/→` (no prefix needed) |
| Resize a pane | `Ctrl+Alt+Shift+arrow` |
| New window (tab) | `prefix + c` |
| Next / prev window | `Alt+→` / `Alt+←` (no prefix) |
| Jump to window N | `Alt+1` … `Alt+9` |
| New / next / prev session | `prefix + C` / `N` / `P` |
| Detach (leave it running) | `prefix + d` |
| Close a pane | `Alt+Esc` (prefix-free) or `prefix + x` |
| Reload this config | `prefix + q` |
| Show all keybindings | `prefix + ?` (popup cheatsheet) |
| Copy mode (scroll/select) | `prefix + [`, then `v` to select, `y` to copy, `q` to exit |

> **Heads-up — prefix collision with zsh.** `Ctrl+Space` is also zsh's default
> *autosuggest-accept*. The zsh config rebinds that to `Ctrl+f` so the two don't
> fight. If you ever change the prefix, keep that in mind.
>
> **Heads-up — macOS steals `Ctrl+Space`.** On macOS, `⌃Space` is the system
> shortcut *Select the previous input source*, handled by the WindowServer
> *before* any app — so the prefix silently does nothing until you turn it off in
> **System Settings → Keyboard → Keyboard Shortcuts → Input Sources** (uncheck
> "Select the previous input source", and the `⌃⌥Space` "next" one). No terminal
> or tmux setting can win this fight; it has to be disabled at the OS level. The
> prefix-free pane keys (`Alt+Enter`, `Alt+Shift+Enter`, `Alt+Esc`) work
> regardless of the prefix.

---

## Line-by-line configuration

### Prefix

```tmux
set -g prefix C-Space        # primary prefix = Ctrl+Space
set -g prefix2 C-b           # secondary prefix = Ctrl+b (the tmux default, kept as a fallback)
bind C-Space send-prefix     # press prefix twice → send a literal Ctrl+Space to the app inside
```

`-g` = "global" (applies to every session). `send-prefix` matters when you run
tmux *inside* tmux (e.g. over SSH): the inner tmux needs a way to receive the
prefix keystroke.

### Config and help

```tmux
bind q source-file ~/.config/tmux/tmux.conf \; display "Configuration reloaded"
bind ? display-popup -E -w 80% -h 70% -T "Tmux keybindings" "tmux list-keys | less -R"
```

`bind q` makes `prefix + q` re-read this file (`source-file`) and flash a
confirmation in the status line (`display`). The `\;` separates two tmux
commands on one line. (This rebinds `q`, which by default cancels copy-mode —
but copy-mode `q` still works because that's a *mode-specific* binding.)

`bind ?` opens a scrollable cheatsheet of every active binding using the
built-in `tmux list-keys` inside a `display-popup` (`-E` closes the popup when
the pager exits). Omarchy's own `prefix + ?` shells out to
`omarchy-menu-tmux-keybindings`, which isn't installed on macOS —
`tmux list-keys` is the zero-dependency equivalent that always works.

### Copy mode (vi-style)

```tmux
setw -g mode-keys vi                                 # use vi keys when scrolling/selecting
bind -T copy-mode-vi v send -X begin-selection       # v starts a selection (like visual mode)
bind -T copy-mode-vi y send -X copy-selection-and-cancel  # y yanks it and exits copy mode
```

Copy mode is how you scroll back through output and copy text with the keyboard.
Enter it with `prefix + [`. With these bindings it feels like Vim: move with
`h/j/k/l`, `v` to start selecting, `y` to copy. `-T copy-mode-vi` = "only bind
this key while inside copy mode".

### Pane controls

```tmux
unbind '"'                                            # drop the default '"' = split-horizontal
unbind %                                              # drop the default '%' = split-vertical
# Prefix-free splits/kill (ported from omarchy dev) — no prefix needed:
bind -n M-Enter   split-window -v -c "#{pane_current_path}"  # Alt+Enter       → split top/bottom
bind -n M-S-Enter split-window -h -c "#{pane_current_path}"  # Alt+Shift+Enter → split side/side
bind -n M-Escape  kill-pane                                  # Alt+Escape      → close the focused pane
bind | split-window -h -c "#{pane_current_path}"      # | → split left/right
bind - split-window -v -c "#{pane_current_path}"      # - → split top/bottom
bind \\ split-window -h -c "#{pane_current_path}"      # \ → same as | (easier to reach)
bind x kill-pane                                       # x → close the focused pane
```

`-h`/`-v` are tmux's (confusing) names: `-h` makes a **h**orizontal *neighbour*
(panes side by side), `-v` stacks them **v**ertically. `-c
"#{pane_current_path}"` opens the new pane in the **same directory** as the
current one — without it, splits open in `$HOME`. The `|` and `-` mnemonics
match the shape of the resulting divider.

The `bind -n M-*` lines are **prefix-free** (`-n` = the root key table) and are
ported verbatim from omarchy's `dev` branch so the muscle memory carries over
from the Linux machine — you split without touching the prefix at all. On macOS
they fire from the **left** ⌥ (Option) key, because Ghostty is set to
`macos-option-as-alt = left` (right ⌥ still types accented characters). This is
also the escape hatch when the `Ctrl+Space` prefix is being swallowed by macOS
(see the input-source heads-up above).

```tmux
bind -n C-M-Left  select-pane -L      # Ctrl+Alt+Left  → focus pane to the left
bind -n C-M-Right select-pane -R      # … right
bind -n C-M-Up    select-pane -U      # … up
bind -n C-M-Down  select-pane -D      # … down
```

`-n` = "no prefix" (the key works on its own). `C-M-` = `Ctrl+Alt`. So pane
navigation is prefix-free — just hold `Ctrl+Alt` and tap an arrow.

```tmux
bind -n C-M-S-Left  resize-pane -L 5  # Ctrl+Alt+Shift+Left  → grow/shrink pane by 5 cells
bind -n C-M-S-Down  resize-pane -D 5
bind -n C-M-S-Up    resize-pane -U 5
bind -n C-M-S-Right resize-pane -R 5
```

Add `Shift` to the same chord to resize instead of move.

### Window (tab) navigation

```tmux
bind r command-prompt -I "#W" "rename-window -- '%%'"   # prefix+r → rename window (prefilled with current name)
bind c new-window -c "#{pane_current_path}"             # prefix+c → new window in same dir
bind k kill-window                                       # prefix+k → close window
```

`command-prompt -I "#W"` pops a prompt pre-filled (`-I`) with the current window
name (`#W`); `%%` is where your typed text is substituted.

```tmux
bind -n M-1 select-window -t 1        # Alt+1 → jump straight to window 1
…                                     # (Alt+2 … Alt+9 likewise)
bind -n M-9 select-window -t 9
bind -n M-Left  select-window -t -1   # Alt+Left  → previous window
bind -n M-Right select-window -t +1   # Alt+Right → next window
bind -n M-S-Left  swap-window -t -1 \; select-window -t -1   # Alt+Shift+Left → move this window left
bind -n M-S-Right swap-window -t +1 \; select-window -t +1   # … right
```

`M-` = `Alt`. The `swap-window` pair lets you reorder tabs without the prefix:
it swaps with the neighbour, then follows the window so focus stays on it.

### Session controls

```tmux
bind R command-prompt -I "#S" "rename-session -- '%%'"  # prefix+R → rename session
bind C new-session -c "#{pane_current_path}"            # prefix+C → brand-new session
bind K kill-session                                     # prefix+K → kill whole session
bind P switch-client -p                                 # prefix+P → previous session
bind N switch-client -n                                 # prefix+N → next session
bind -n M-Up   switch-client -p                         # Alt+Up   → previous session (no prefix)
bind -n M-Down switch-client -n                         # Alt+Down → next session
```

Note the **capital** letters for sessions vs **lowercase** for windows
(`c`/`C`, `k`/`K`, `r`/`R`) — a consistent "Shift = session-level" convention.

### General behaviour

```tmux
set -g default-terminal "tmux-256color"   # advertise a 256-colour, modern terminfo to apps
set -ag terminal-overrides ",*:RGB"       # append: tell tmux every terminal supports 24-bit truecolor
set -g mouse on                           # click panes/windows, drag borders, scroll with the wheel
set -g base-index 1                       # number windows from 1 (so it matches Alt+1)
setw -g pane-base-index 1                 # number panes from 1 too
set -g renumber-windows on                # close a window → renumber the rest, no gaps
set -g history-limit 50000                # keep 50k lines of scrollback per pane
set -g escape-time 0                      # no delay after Esc (matters a lot inside nvim)
set -g focus-events on                    # forward focus-gained/lost to apps (nvim autoread, etc.)
set -g set-clipboard on                   # let programs set the system clipboard via OSC 52
set -g allow-passthrough on               # let apps send raw escape sequences through tmux (images, OSC 52)
setw -g aggressive-resize on              # resize a window to the smallest *attached* client, not the smallest that ever saw it
set -g detach-on-destroy off              # when a session's last window closes, switch to another session instead of detaching
set -g extended-keys on                   # support extended key encodings (Ctrl+Enter, etc.)
set -g extended-keys-format csi-u         # …using the CSI-u scheme nvim/modern apps understand
set -sg escape-time 10                    # server-level escape-time (see note)
```

`-a` on `terminal-overrides` means *append* rather than replace, so the truecolor
hint adds to tmux's built-in defaults instead of wiping them.

> **Two `escape-time` lines.** Line near the top sets `escape-time 0` (session
> option, `-g`); the last line sets `escape-time 10` at the **server** level
> (`-sg`). The server-level one is the one that actually takes effect — 10 ms is
> a safe value that still feels instant while avoiding misread escape sequences
> on slow links. Harmless redundancy; the `0` is effectively dead.

### Status bar

```tmux
set -g status-position top         # bar at the top of the screen
set -g status-interval 5           # redraw the bar every 5s (clock/host updates)
set -g status-left-length 30       # max width for the left segment
set -g status-right-length 50      # max width for the right segment
set -g window-status-separator ""  # no gap between window labels
setw -g automatic-rename on        # auto-name windows…
setw -g automatic-rename-format '#{b:pane_current_path}'   # …to the basename of the current directory
```

`#{b:...}` is tmux's "basename" formatter, so a window sitting in
`~/GITHUB/dotfiles` shows up as `dotfiles`.

### Theme

```tmux
set -g status-style "bg=default,fg=default"
set -g status-left  "#[fg=black,bg=blue,bold] #S #[bg=default] "
set -g status-right "#[fg=blue]#{?pane_in_mode,COPY ,}#{?client_prefix,PREFIX ,}#{?window_zoomed_flag,ZOOM ,}#[fg=brightblack]#h "
set -g window-status-format         "#[fg=brightblack] #I:#W "
set -g window-status-current-format "#[fg=blue,bold] #I:#W "
set -g pane-border-style        "fg=brightblack"
set -g pane-active-border-style "fg=blue"
set -g message-style         "bg=default,fg=blue"
set -g message-command-style "bg=default,fg=blue"
set -g mode-style "bg=blue,fg=black"
setw -g clock-mode-colour blue
```

The theme uses **named** colours (`default`, `blue`, `black`, `brightblack`)
rather than hex. That's intentional: tmux maps those names to your terminal's
current palette, so the bar automatically re-themes whenever Omarchy switches
the active colour scheme — no hardcoded hex to update.

Reading the segments:
- `status-left` shows the **session name** (`#S`) as a blue badge.
- `status-right` shows three **conditional flags** —
  `#{?pane_in_mode,COPY ,}` prints `COPY ` only while in copy mode, similarly
  `PREFIX ` (you've pressed the prefix and tmux is waiting) and `ZOOM ` (a pane
  is zoomed full-screen via `prefix + z`) — then the **hostname** (`#h`).
- `window-status[-current]-format` renders each tab as `index:name` (`#I:#W`),
  with the focused one bold-blue.
- `#[...]` blocks are inline colour directives; `#{...}` are format expansions.

---

## Common workflows

**Persistent dev session.** Run `tmux new -s work`, set up your panes, then
`prefix + d` to detach. Closing the terminal (or losing SSH) leaves everything
running. Come back with `tmux attach -t work`. The `SUPER ALT + RETURN` Hyprland
binding (see `../hypr/README.md`) does exactly this: `tmux attach || tmux new -s Work`.

**Seamless nvim ↔ tmux navigation.** Neovim's `vim-tmux-navigator` plugin and
this config's `Ctrl+Alt+arrows` are *separate* mechanisms — the nvim plugin uses
`Ctrl+h/j/k/l` to hop between Vim splits and tmux panes as if they were one grid.
See `../nvim/docs/` for that side.

**Copy text without the mouse.** `prefix + [` enters copy mode, navigate with
Vim keys, `v` to start the selection, `y` to copy to the system clipboard (works
because `set-clipboard on` + OSC 52 passthrough), `q` to exit.

## Validate after editing

Parse the config on a throwaway server so your running tmux is never touched:

```bash
tmux -L _check -f ~/.config/tmux/tmux.conf start-server \; kill-server && echo OK
```

No output before `OK` means it parsed cleanly.
