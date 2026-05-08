# Alacritty

Cross-platform (macOS + Linux) GPU-accelerated terminal. The config lives at
`~/.config/alacritty/alacritty.toml` (whole `~/.config/alacritty` directory is
symlinked from `alacritty/` in this repo). The colour palette is split into
its own file under `themes/` and pulled in by `[general] import`.

`live_config_reload = true` is on, so saving the file applies it — no
restart, no key combo.

## Files

```
alacritty/
├── alacritty.toml                     main config
└── themes/
    └── tokyonight_storm.toml          palette only — imported by alacritty.toml
```

## Authoritative reference

```sh
# Print the schema with annotations (a JSON man-page)
alacritty --print-events                       # tail input events for binding debug
alacritty migrate                              # validate / migrate config to current schema
man 5 alacritty                                # full reference for every option
man 5 alacritty-bindings                       # key/mouse bindings reference
```

The official option reference (in case you'd rather read on the web):
<https://alacritty.org/config-alacritty.html>.

## What this config customizes

The file holds **only customizations** — settings that match Alacritty's
defaults are intentionally absent. Two clusters exist for cross-platform
reasons; see "Cross-platform handling" below.

| Block         | What it does |
|---------------|---------------|
| Theme         | Tokyo Night Storm via `[general] import` of `themes/tokyonight_storm.toml`. Matches the in-pane theme used by nvim, tmux, starship, and bat. |
| Typography    | `CaskaydiaMono Nerd Font Mono` 15 pt. Built-in box-drawing on. `[font.offset] y = 2` adds a few px of cell height (mirrors Ghostty's `adjust-cell-height = 5%`). |
| Window        | 96 % opacity + blur (macOS). 140 × 38 default size, 10 × 8 padding, dynamic title on. `decorations = "Full"` cross-platform; override per-machine on Hyprland. |
| Scrollback    | 50 000 lines, mouse-wheel multiplier `3`. |
| Cursor        | Solid block, non-blinking. Hollow when window is unfocused. Thickness `0.15`. |
| Selection     | `save_to_clipboard = true` (selection → system clipboard). Curated `semantic_escape_chars` so word-double-click stops at typical token boundaries. |
| Mouse         | Hide pointer while typing. |
| Bell          | `EaseOutExpo` animation, `duration = 0` — flashes silently if anything fires the bell. |
| macOS         | `option_as_alt = "OnlyLeft"` matches Ghostty's `macos-option-as-alt = left`. Right-Option keeps its OS-level diacritic behaviour. |

## Notable non-default choices

- **`live_config_reload = true`** — Alacritty re-reads the file on save.
  Default is also `true` since 0.13, but this is kept explicit so a future
  default flip doesn't surprise you.
- **`save_to_clipboard = true`** — Alacritty's default copies *only* to the
  selection clipboard (PRIMARY on Linux), which is invisible on macOS. With
  this on, a mouse selection lands in the regular system clipboard too.
- **`semantic_escape_chars = ",│`|:\"' ()[]{}<>\t"`** — adds the box-drawing
  vertical bar `│` on top of the default set. Useful when double-clicking
  inside tmux or `ls -l` output.
- **`builtin_box_drawing = true`** — Alacritty draws box/braille glyphs
  itself instead of using the font's. Pixel-aligned at any zoom level.
- **`option_as_alt = "OnlyLeft"`** (macOS) — Left-Option behaves as Alt
  (vim/zsh/tmux all want this). Right-Option keeps the OS diacritic flow
  (`⌥e e` → `é`).

## Keybinds

`Command` = Cmd on macOS, Super on Linux (Alacritty aliases them). Listed
bindings are the **additions** in this config; Alacritty has its own
defaults too — run `man 5 alacritty-bindings` for the full default set.

Splits and tabs are intentionally **absent**: use tmux for that.

### Font size

| Keys                           | Action              |
|--------------------------------|---------------------|
| `super+=` / `ctrl+shift+=`     | Increase font size  |
| `super+-` / `ctrl+shift+-`     | Decrease font size  |
| `super+0` / `ctrl+shift+0`     | Reset font size     |

### Window / clipboard

| Keys                           | Action            |
|--------------------------------|-------------------|
| `super+n` / `ctrl+shift+n`     | New window        |
| `super+c`                      | Copy (macOS)      |
| `super+v`                      | Paste (macOS)     |
| `ctrl+shift+c` / `ctrl+shift+v` | Copy / paste (Linux — Alacritty default) |
| `super+k` / `ctrl+shift+k`     | Clear scrollback (visible region: use shell Ctrl-L or `clear`) |

### Defaults you might also want to know

| Keys                           | Action                     | Source  |
|--------------------------------|----------------------------|---------|
| `ctrl+shift+space`             | Toggle Vi mode             | default |
| `ctrl+shift+f`                 | Search forward             | default |
| `ctrl+shift+b`                 | Search backward            | default |
| `ctrl+shift+pageup` / `down`   | Scroll page                | default |
| `ctrl+shift+home` / `end`      | Scroll to top / bottom     | default |

In Vi mode, `y` yanks, `/` searches, `v` selects — same as you'd expect.

## Cross-platform handling

Alacritty silently ignores options that aren't valid on the current
platform, which lets one TOML file cover both:

| Option                              | Honoured on | Ignored on    |
|-------------------------------------|-------------|---------------|
| `window.blur`                       | macOS       | Linux         |
| `window.option_as_alt`              | macOS       | Linux         |
| `window.decorations_theme_variant`  | Linux/Wayland | macOS       |

`window.decorations` is honoured on both, but the values differ:

- **macOS:** `"Full"`, `"Buttonless"`, `"Transparent"`, `"None"`.
- **Linux:** `"Full"`, `"None"`.

This config sets `"Full"`. On Hyprland you typically want `"None"` — see
"Machine-local overrides" below for the clean way to do that.

## Machine-local overrides

The `[general] import` array has a commented-out second entry:

```toml
import = [
  "~/.config/alacritty/themes/tokyonight_storm.toml",
  # "~/.config/alacritty/config.local.toml",
]
```

To opt in:

1. Uncomment the line.
2. Create `~/.config/alacritty/config.local.toml` with whatever you want to
   override. **Note:** the file must exist — Alacritty has no `?`-style
   "skip if missing" syntax (unlike Ghostty).

Examples:

```toml
# ~/.config/alacritty/config.local.toml — Hyprland
[window]
decorations = "None"
```

```toml
# ~/.config/alacritty/config.local.toml — 4K external display
[font]
size = 17.0
```

Imports merge over the base config; later imports win.

## Theme

`themes/tokyonight_storm.toml` is the full Tokyo Night *Storm* palette
(`#24283b` background) — same variant used by `folke/tokyonight.nvim` and
matched by tmux, starship, and bat in this repo. To switch palettes, drop a
new theme file next to it and change the import line in `alacritty.toml`.

The repo currently ships only the one theme; if you want more, `alacritty-themes`
on GitHub (<https://github.com/alacritty/alacritty-theme>) has hundreds of
ready-to-import TOMLs.

## Troubleshooting

### Config didn't reload

`live_config_reload` is on, but it triggers on **save** of the *resolved*
file. Editing through the symlink works (it's the same inode). If you
edited an imported file (`themes/...`), Alacritty re-imports — but if
something looks stuck, validate first:

```sh
alacritty migrate /Users/mo/.config/alacritty/alacritty.toml
```

This dry-runs the parser and reports schema errors.

### Glyphs render as tofu

You need a Nerd Font, both installed *and* selected. The cask
`font-caskaydia-mono-nerd-font` provides the one this config asks for.
Confirm with:

```sh
fc-list | grep -i caskaydia       # Linux
ls "/Library/Fonts" "$HOME/Library/Fonts" | grep -i caskaydia  # macOS
```

### Cmd-key bindings don't fire on Linux

On Linux, `Command` aliases `Super` (the Windows / Logo key). If your
window manager already grabs Super-N, Super-K, Super-C, etc., Alacritty
never sees the keystroke. Either remap your WM (Hyprland's `bind = ` /
sway's `bindsym`), or rely on the `Control|Shift` variants documented above.

### Right-Option types `é` instead of behaving as Alt

That's intentional — `option_as_alt = "OnlyLeft"`. Use **Left-Option** for
Alt-prefixed bindings. Flip to `option_as_alt = "Both"` in
`config.local.toml` if you'd rather lose the diacritics.

### tmux thinks it's xterm-256color, not alacritty

The `alacritty` terminfo entry needs to be installed. Homebrew installs it
automatically with the cask; on minimal Linux:

```sh
sudo tic -xe alacritty,alacritty-direct /usr/share/alacritty/alacritty.info
```

(or grab `alacritty.info` from the upstream repo). Verify with
`infocmp alacritty | head -1`. Until that's done, tmux sees a mismatch and
reports the wrong terminfo on session start.

### Colors look washed out inside tmux or nvim

Their terminfo must advertise RGB. The tmux config in this repo already
sets `terminal-features ",*:RGB"`. nvim defaults to `termguicolors` via
LazyVim. If colors still look 256-ish, double-check no parent shell
exported `COLORTERM=` to something other than `truecolor`.
