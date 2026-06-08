# Alacritty

**Alacritty** is a fast, GPU-accelerated terminal emulator. It's deliberately
minimal — no tabs, no splits, no built-in multiplexing (that's tmux's job). It
just draws a terminal grid very quickly. Configuration is a single TOML file.

- **Live path:** `~/.config/alacritty` → symlink → `alacritty/` (this dir)
- **Editing `alacritty.toml` here edits the live config.** Alacritty **watches
  the file and reloads on save** — no restart needed.
- On Omarchy this is a *secondary* terminal (Ghostty is the daily driver), but
  it's fully configured and theme-synced.

## How it fits together

Alacritty has no theme of its own here — it **imports** the colours from
Omarchy's current theme. When you switch themes in Omarchy, the imported file is
rewritten and Alacritty live-reloads into the new palette automatically. Your
personal settings (font, padding, keybinds) live in this file and are never
touched by the theme switch.

---

## Line-by-line configuration

### Theme import

```toml
general.import = [ "~/.config/omarchy/current/theme/alacritty.toml" ]
```

Pulls in the colour scheme from Omarchy's "current theme" symlink. `import` is a
list, so you could layer more files; here it's just the theme. Settings in *this*
file override anything the import sets, because the import is listed first and
later keys win. This is the single line that makes Alacritty follow the system
theme.

### Environment

```toml
[env]
TERM = "xterm-256color"
```

Sets the `$TERM` variable that programs read to decide what escape sequences the
terminal understands. `xterm-256color` is the safe, universally-recognised value
(some remote hosts don't ship Alacritty's own `alacritty` terminfo, so this
avoids "unknown terminal" errors over SSH).

### Terminal

```toml
[terminal]
osc52 = "CopyPaste"
```

`OSC 52` is an escape sequence that lets a program running in the terminal —
including one on a **remote** machine over SSH, or inside tmux — set your local
clipboard. `"CopyPaste"` allows both reading and writing. This is what makes
"yank in remote nvim → paste locally" work.

### Font

```toml
[font]
normal = { family = "CaskaydiaMono Nerd Font Mono" }
bold   = { family = "CaskaydiaMono Nerd Font Mono" }
italic = { family = "CaskaydiaMono Nerd Font Mono" }
size = 9
```

One font for all three styles: **CaskaydiaMono Nerd Font Mono** — a patched
Cascadia Code that includes the thousands of extra "Nerd Font" glyphs (icons used
by Starship, the file tree, statuslines, fastfetch, etc.). The `Mono` variant
forces every glyph to a single cell width, which keeps columns aligned. `size =
9` is the point size — small, for dense text; bump it if it's too tight.

### Window

```toml
[window]
padding.x = 14
padding.y = 14
decorations = "None"
```

- `padding.x / .y = 14` — 14px of breathing room between the text grid and the
  window edge on each axis.
- `decorations = "None"` — no title bar / window border drawn by the terminal.
  On a tiling Wayland compositor (Hyprland) the compositor manages window frames,
  so the terminal's own decorations would be redundant chrome.

### Keyboard

```toml
[keyboard]
bindings = [
  { key = "Insert", mods = "Shift",   action = "Paste" },
  { key = "Insert", mods = "Control", action = "Copy"  },
  { key = "Return", mods = "Shift",   chars  = "\u001B\r" }
]
```

- `Shift+Insert` → **Paste**, `Ctrl+Insert` → **Copy**. These are the classic
  X11/Linux clipboard chords, added back because they're muscle memory for many
  people and don't clash with shell shortcuts.
- `Shift+Return` → send the bytes `\r`, i.e. **Escape followed by Carriage
  Return** (`Esc` + `Enter`). This is the CSI/"alt-enter" trick that lets apps
  like nvim or a REPL distinguish *Shift+Enter* (e.g. "insert newline without
  submitting") from a plain *Enter*. Terminals can't send Shift+Enter natively,
  so this encodes it as a sequence the app can detect.

### Selection

```toml
[selection]
save_to_clipboard = true   # Ghostty parity: copy-on-select = clipboard.
```

When you select text with the mouse, it's copied to the **system clipboard**
immediately (not just the primary/middle-click buffer). The comment notes this
mirrors how Ghostty is configured, so both terminals behave the same.

### Mouse

```toml
[mouse]
hide_when_typing = true
```

Hides the mouse cursor as soon as you start typing, so it doesn't sit on top of
the text you're reading. It reappears when you move the mouse.

---

## Best use cases

- **As a tmux host.** Alacritty does one thing fast; let tmux handle
  splits/tabs/sessions on top. The two are a classic pairing.
- **SSH / remote work.** The `xterm-256color` TERM + OSC 52 clipboard make remote
  sessions behave well, including clipboard from the far end.
- **A lightweight fallback** when you want a no-frills, instant terminal.

## Validate after editing

```bash
# Check for deprecated keys / migration notes (operates on a copy if you want):
alacritty migrate --dry-run -c ~/.config/alacritty/alacritty.toml
```

A clean run reports no changes needed. (Alacritty also live-reloads on save, so
a syntax error simply shows up as an on-screen error overlay rather than killing
the terminal.)

## Reference

- Config reference (every key): `man 5 alacritty` or
  <https://alacritty.org/config-alacritty.html>
