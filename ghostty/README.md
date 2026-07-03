# Ghostty

**Ghostty** is the primary terminal emulator on the **macOS machine** — a fast,
GPU-accelerated, zero-daemon terminal by Mitchell Hashimoto. This directory
holds its single `config` file (Ghostty's plain `key = value` format, not TOML).

- **Live path:** `~/.config/ghostty` → symlink → `ghostty/` (whole dir).
  Ghostty reads `$XDG_CONFIG_HOME/ghostty/config` on macOS too, so the repo's
  standard whole-dir symlink model works unchanged.
- **macOS-only.** The Omarchy box uses Alacritty (`alacritty/`); nothing here is
  sourced on Arch. The config deliberately uses `macos-*` options and `super+`
  (⌘) keybinds.
- **Reload:** `super+shift+r` inside Ghostty, or just open a new window —
  Ghostty re-reads config per-surface. No live file-watch like Alacritty.
- **Machine-local overrides** go in `ghostty/config.local` (gitignored). The
  last line of `config` imports it with the `?` prefix, meaning "no error if the
  file doesn't exist". The path resolves relative to the config file's
  directory, which is why the whole-dir symlink matters.

> **Gotcha:** Ghostty only loads a file literally named `config`. On macOS it
> *also* reads `~/Library/Application Support/com.mitchellh.ghostty/config`
> (loaded *after* the XDG file, so it wins conflicts). Keep that location empty
> so this repo stays the single source of truth.

---

## Line-by-line configuration

### Font

```ini
font-family               = "CaskaydiaMono Nerd Font Mono"
font-size                 = 15
font-thicken              = true
font-thicken-strength     = 100
adjust-cell-height        = 5%
adjust-underline-position = 1
```

- `font-family` — CaskaydiaMono Nerd Font, the **Mono** (fixed-icon-width)
  variant, so Nerd Font glyphs in prompts/nvim don't overflow their cell.
  Install: `brew install --cask font-caskaydia-mono-nerd-font` (files land in
  `~/Library/Fonts/` — note they are **per-user**). If the font is missing,
  Ghostty silently falls back to its bundled JetBrains Mono.
- `font-thicken` + `font-thicken-strength = 100` — macOS-style stem darkening
  (0–255); makes light-on-dark text less spindly on Retina displays.
- `adjust-cell-height = 5%` — adds line breathing room without changing the
  glyph size (like `line-height`).
- `adjust-underline-position = 1` — drops the underline 1px so it doesn't
  collide with descenders.

### Colors & cursor

```ini
background-opacity      = 0.96
background-blur         = true
selection-foreground    = #cad3f5
selection-background    = #5b6078
cursor-style            = block
cursor-style-blink      = false
cursor-color            = #8aadf4
cursor-text             = #24273a
mouse-hide-while-typing = true
unfocused-split-fill    = #1e2030
unfocused-split-opacity = 0.85
```

- Slight translucency + native macOS blur behind the window.
- The hex values are **Catppuccin Macchiato** accents (text `#cad3f5`, surface
  `#5b6078`, blue `#8aadf4`, base `#24273a`, mantle `#1e2030`) — selection and
  cursor stay on-palette with the shell/nvim theme.
- Non-blinking block cursor, matching the tmux/nvim setup.
- Unfocused splits dim to 85 % over a mantle-colored fill so the active split
  is obvious.

### Clipboard

```ini
clipboard-read     = ask
clipboard-write    = allow
copy-on-select     = clipboard
right-click-action = copy-or-paste
```

Explicit values lock against upstream default drift. `clipboard-read = ask`
means programs using OSC 52 to *read* your clipboard trigger a prompt
(paste-jacking guard); writes are allowed silently. Selecting text copies
immediately; right-click copies if there's a selection, otherwise pastes.

### Window

```ini
maximize                 = true
window-save-state        = never
window-padding-x         = 10
window-padding-y         = 8
window-padding-balance   = true
window-colorspace        = display-p3
resize-overlay-duration  = 1s
confirm-close-surface    = false
```

- `maximize = true` — every new window opens **maximized**: a normal zoomed
  window, *not* macOS native fullscreen (that's the separate `fullscreen`
  option, left at its default `false`, so no extra Space is created).
- `window-save-state = never` — never restore last-quit geometry/tabs/splits.
  The pair above is what guarantees a full-size window on every launch.

> **History:** this block used to set `window-width/height = 140×38` with
> `window-save-state = always`. That combination resurrected whatever
> position/size the window was last left in (minimized, dragged to a corner…)
> and otherwise opened a fixed smaller window that macOS parked top-left.
> `window-step-resize` (cell-snapped resizing) was dropped at the same time —
> with a maximized-by-default window it was dead config, and resizing is now
> smooth pixel increments.

- Padding balanced so leftover pixels split evenly around the grid instead of
  piling up on one edge.
- `display-p3` — use the full wide-gamut display instead of clamping to sRGB.
- `confirm-close-surface = false` — no "process is running" nag on close.

### Shell integration

```ini
shell-integration          = zsh
shell-integration-features = cursor,sudo,title,ssh-env,ssh-terminfo,path
```

Pinned to zsh (the macOS login shell — see `zsh/README.md`) instead of
`detect`. Features: prompt-aware cursor, sudo wrapper, window titles, and the
two `ssh-*` helpers that keep `TERM=xterm-ghostty` from breaking remote hosts
by shipping terminfo / downgrading the env over SSH.

### Quick terminal

```ini
quick-terminal-size               = 34%
quick-terminal-animation-duration = 0.18
```

A drop-down (iTerm "hotkey window" style) terminal covering the top 34 % of the
screen, toggled with `super+ctrl+space` (bound below), with a fast 180 ms slide.

### macOS security

```ini
macos-option-as-alt           = left
macos-auto-secure-input       = true
macos-secure-input-indication = true
macos-non-native-fullscreen   = visible-menu
```

Left ⌥ acts as Alt (right ⌥ still types symbols); Secure Keyboard Entry
auto-enables at password prompts (with a visual indicator); fullscreen is the
fast non-native kind but keeps the menu bar visible.

> **macOS grabs `Ctrl+Space`.** Not set in this file, but it bites terminal
> users: macOS binds `⌃Space` to *Select the previous input source* at the
> WindowServer level, so it never reaches Ghostty (or tmux, whose default prefix
> is `Ctrl+Space`). Disable it in **System Settings → Keyboard → Keyboard
> Shortcuts → Input Sources**. See `tmux/README.md` for the full story.

### Keybinds

All bindings are **pinned Ghostty defaults** — kept explicit so a future
upstream rebind can't move them silently (same defensive-lock pattern as the
clipboard block). Groups: quick terminal / reload / open-config, splits
(`super+d`, `super+shift+hjkl` vim-style navigation, `super+shift+z` zoom),
tabs (`super+1..9`, `super+shift+[`/`]`), font size (`super+=`/`-`), and
`super+k` clear. Run `ghostty +list-keybinds` for the full effective set.

Two bindings are **removed**, not added, for tmux's sake:

```ini
keybind = alt+left=unbind
keybind = alt+right=unbind
```

Ghostty ships an emacs-style word-jump on `Option+Left/Right`
(`alt+left=esc:b` / `alt+right=esc:f`) that consumes those keys before the TTY
forwards them — so tmux's omarchy `Alt+Left`/`Alt+Right` window navigation never
fires. Unbinding lets the raw `M-Left`/`M-Right` reach tmux. Trade-off: no
word-by-word cursor motion via `Option+Arrow` in a plain (non-tmux) shell.

### Local overrides

```ini
config-file = ?config.local
```

Optional per-machine file, gitignored (see repo `.gitignore`). Later values win,
so anything set there overrides this file.

---

## Validate after editing

```sh
ghostty +validate-config          # parse + semantic check of the live config
ghostty +show-config              # dump the effective (non-default) values
ghostty +list-fonts --family="CaskaydiaMono Nerd Font Mono"   # font resolves?
ghostty +list-keybinds            # effective keybinds incl. the pinned ones
```

`+validate-config` exits 0 silently when the config is clean. Then reload a
running window with `super+shift+r` (config errors surface in a dedicated
error window, they never crash the terminal).
