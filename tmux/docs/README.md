# tmux — Quick Reference

Concise binding cheatsheet. For walkthrough-style explanations of *why* and *when* to use each, see [`../TMUX-GUIDE.md`](../TMUX-GUIDE.md).

- **Config:** `~/.config/tmux/tmux.conf` (symlink → `dotfiles/tmux/tmux.conf`)
- **Prefix:** `Ctrl+Space`
- **Theme:** Tokyo Night Storm (inline)
- **Bootstrap:** TPM auto-clones on first start. Then: `prefix + I` to install plugins.

---

## Core

| Keys             | Action |
|------------------|--------|
| `prefix + ,`     | Reload config (live) |
| `prefix + ?`     | List every active binding |
| `prefix + d`     | Detach |
| `prefix + e`     | Respawn pane (after `remain-on-exit failed` kept it open) |
| `prefix + t`     | Show fullscreen clock |

## Sessions

| Keys             | Action |
|------------------|--------|
| `prefix + s`     | Built-in session/window tree picker |
| `prefix + O`     | sessionx — fzf session picker with previews |
| `prefix + N`     | New session (prompts for name, inherits cwd) |
| `prefix + S`     | Rename current session (prefilled) |
| `prefix + X`     | Kill current session (confirm) |
| `Alt+Up` / `Alt+Down` | Previous / next session (no prefix) |

## Windows

| Keys             | Action |
|------------------|--------|
| `prefix + c`     | New window (inherits cwd, auto-named) |
| `prefix + C`     | New window (prompts for name) |
| `prefix + r`     | Rename current window (prefilled) |
| `prefix + Tab`   | Last window *(extrakto plugin overrides — see Conflicts)* |
| `prefix + n` / `prefix + p` | Next / prev window (repeatable) |
| `Alt+1`…`Alt+9`  | Jump directly to window 1–9 (no prefix) |
| `prefix + b`     | Break pane out into its own window |
| `prefix + B`     | Pull a pane from another window into this one |

## Splits

| Keys             | Action |
|------------------|--------|
| `prefix + \|`    | Vertical split (cwd preserved) |
| `prefix + \\`    | Same — alias (no Shift needed) |
| `prefix + -`     | Horizontal split |

## Pane navigation & motion

| Keys             | Action |
|------------------|--------|
| `Ctrl+h/j/k/l`   | Move between panes — seamless with Neovim splits (vim-tmux-navigator, no prefix) |
| `prefix + ;`     | Last-active pane |
| `prefix + H/J/K/L` | Resize border (5 cells, repeatable) |
| `prefix + <` / `>` | Swap pane and follow it |
| `prefix + z`     | Toggle zoom (fill window) — default |
| `prefix + q`     | Show pane numbers; press digit to jump — default |
| `prefix + Space` | Cycle layouts *(thumbs plugin overrides — see Conflicts)* |

## Pane actions

| Keys             | Action |
|------------------|--------|
| `prefix + x`     | Kill pane (no confirm) |
| `prefix + Ctrl+l`| Send `Ctrl+L` and clear scrollback |
| `prefix + m` / `M` | Mark / unmark pane (referenced as `~` by join-pane / swap-pane) |
| `prefix + P`     | Toggle synchronize-panes (broadcast input; status shows purple SYNC) |
| `prefix + *`     | Toggle pipe-pane logging to `~/.local/state/tmux/<session>-<window>-<pane>.log` |
| `prefix + g`     | Popup scratch shell (80%×80%, persistent `scratch` session, current cwd) |

## Copy mode (vi)

Enter with `prefix + v` (or `prefix + [`). Status shows yellow `COPY`.

| Keys             | Action |
|------------------|--------|
| `h j k l`        | Char motions |
| `w` / `b`        | Word forward / back |
| `0` / `$`        | Line start / end |
| `Ctrl+u` / `Ctrl+d` | Half-page up / down |
| `g` / `G`        | Top / bottom of scrollback |
| `/` / `?`        | Incremental search down / up |
| `n` / `N`        | Next / previous match |
| `v`              | Begin selection |
| `Ctrl+v`         | Toggle rectangle / block selection |
| `y` or `Enter`   | Yank to system clipboard, exit |
| `o`              | tmux-open: open URL/path under cursor |
| Mouse drag       | Select; auto-yank on release |

## Plugin extras

| Keys             | Action |
|------------------|--------|
| `prefix + u`     | tmux-fzf-url — fuzzy-pick a URL from visible text |
| `prefix + Space` | tmux-thumbs — vimium-style hint copy |
| `prefix + Shift+Space` | tmux-thumbs — copy and open |
| `prefix + Tab`   | extrakto — fzf over visible pane text |
| `prefix + Ctrl+s`| tmux-resurrect save |
| `prefix + Ctrl+r`| tmux-resurrect restore |

## Plugin management

| Keys             | Action |
|------------------|--------|
| `prefix + I`     | Install plugins from `tmux.conf` |
| `prefix + U`     | Update installed plugins |
| `prefix + Alt+u` | Uninstall plugins removed from `tmux.conf` |

---

## Known binding conflicts

These are **intentional** — plugin bindings load after the main config and override these defaults. If you want the original default back, override the plugin's option to a different key (in `tmux.conf`).

| Default key   | Default action     | Currently bound to | Restore default by |
|---------------|--------------------|--------------------|--------------------|
| `prefix + Tab` | `last-window`      | extrakto           | `set -g @extrakto_key 'e'` (or any free key) |
| `prefix + Space` | `next-layout`    | tmux-thumbs        | `set -g @thumbs-key '<other>'`                |
| `prefix + Ctrl+l` | `send-keys C-l` (after vim-tmux-navigator) | `send-keys C-l \; clear-history` | (already disabled via `@vim_navigator_prefix_mapping_clear_screen ''`) |

---

## Plugins

Declared in order under the **PLUGINS** section of `tmux.conf`:

| Plugin                          | Purpose |
|---------------------------------|---------|
| `tmux-plugins/tpm`              | Plugin manager itself (must be first). |
| `tmux-plugins/tmux-resurrect`   | Save/restore sessions and pane contents. Neovim session restore via `@resurrect-strategy-nvim` requires a Neovim session plugin to write the session file on exit. |
| `tmux-plugins/tmux-continuum`   | Auto-saves every 15 min, auto-restores on tmux server start. |
| `tmux-plugins/tmux-yank`        | OSC-52 + pbcopy / xclip / xsel auto-detection. |
| `christoomey/vim-tmux-navigator`| Seamless `Ctrl+h/j/k/l` between tmux panes and Neovim splits. Requires the matching Neovim plugin. |
| `omerxx/tmux-sessionx`          | fzf session picker with previews (`prefix + O`). |
| `tmux-plugins/tmux-open`        | In copy mode, `o` opens the highlighted path/URL. |
| `wfxr/tmux-fzf-url`             | `prefix + u` fuzzy-picks any visible URL. |
| `fcsonline/tmux-thumbs`         | Vimium-style hint jumps to copy/open paths, hashes, URLs, IPs. |
| `laktak/extrakto`               | fzf over all visible pane text; yank or insert at prompt. |

---

## Terminal capabilities (the why)

| Setting | Effect |
|---------|--------|
| `default-terminal "tmux-256color"` | 256-color support inside tmux. |
| `terminal-features ",*:RGB"` | 24-bit color (3.2+ preferred form). |
| `terminal-features ",*:usstyle"` | Curly / dotted / dashed underlines (LSP diagnostics in Neovim). |
| `allow-passthrough on` | Inline image protocols (kitty/Ghostty); active pane only — `all` would be too permissive over SSH. |
| `set-clipboard on` | OSC-52 clipboard passthrough. |
| `focus-events on` | Forwards focus changes to inner programs (Neovim autoread, dim-on-blur). |
| `escape-time 10` | Snappy mode-switching in Neovim (default 500 ms is sluggish). |
| `repeat-time 600` | Window for `-r` repeat bindings (resize, swap, next-window). |
| `history-limit 50000` | Lines of scrollback per pane. |
| `window-size largest` | Resize each window to its largest connected client. |
| `detach-on-destroy off` | Killing the current session switches to next, doesn't drop you out of tmux. |
| `set -g remain-on-exit failed` | Crashed panes stay open with output visible; `prefix + e` to respawn. |

---

## Status bar

Tokyo Night palette, top-positioned, `status-interval 60` (no widgets that need refreshing).

- **Left:** `#S` — current session name on blue.
- **Window list:** dimmed for inactive, blue accent + bold for active, yellow underline for activity, red bold for bell.
- **Right:** state badges only — `PREFIX` / `COPY` / `ZOOM` / `SYNC`. Empty otherwise (no clock).
- **Pane borders:** dim line for inactive, blue for active. Border title shows `#P #{pane_current_command}`.

---

## Sessions across restarts

resurrect + continuum:

1. Every 15 min, sessions (incl. pane contents) snapshot to `~/.local/share/tmux/resurrect/`.
2. Next tmux server start auto-restores from the latest snapshot.
3. Manual save / restore: `prefix + Ctrl+s` / `prefix + Ctrl+r`.

**Not** restored: live process state. resurrect re-runs the recorded command line; it doesn't preserve PIDs, file handles, or in-memory state. Programs in `@resurrect-processes` (`ssh nvim vim vi htop btop k9s less more man tail watch`) get respawned by command.

> **Privacy:** Pane-contents capture writes whatever scrolled by. Wipe `~/.local/share/tmux/resurrect/` if you ever pasted credentials.

---

## Troubleshooting

- **TPM didn't bootstrap.** `git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm`, then `prefix + ,` reload, `prefix + I` install.
- **Colors washed out.** `tmux info | grep -i rgb` should print `RGB: (flag) true`. If not, the outer terminal isn't advertising 24-bit color.
- **Clipboard broken on macOS old.** `brew install reattach-to-user-namespace` and uncomment the Darwin `if-shell` block at the bottom of `tmux.conf`.
- **`Ctrl+Space` not reaching tmux.** Test outside tmux with `cat`. If nothing echoes, terminal swallows it — re-bind in the terminal or change tmux prefix to `C-a`.
- **`prefix + u` does nothing.** Install `fzf`.
- **`prefix + Tab` opens fzf instead of last-window.** That's extrakto. Set `@extrakto_key 'e'` to free Tab.
- **thumbs first run is slow.** It compiles a Rust binary. `brew install tmux-thumbs` to skip the cargo build.

---

## Layout

```
~/.config/tmux/                          (symlink → dotfiles/tmux/)
├── tmux.conf                             main config — heavily commented
├── TMUX-GUIDE.md                         long-form learning guide
├── docs/
│   └── README.md                         this file (quick reference)
└── plugins/                              TPM-managed; auto-populated
    ├── tpm/
    └── ...
```
