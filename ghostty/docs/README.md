# Ghostty

macOS-native terminal emulator. The config lives at `~/.config/ghostty/config` (symlinked from this repo) and loads optional machine-local overrides from `~/.config/ghostty/config.local` when present.

Authoritative reference for every option:

```sh
ghostty +show-config --default --docs | less
ghostty +list-keybinds --default
```

Validate the file after edits:

```sh
ghostty +validate-config --config-file=~/.config/ghostty/config
```

## What this config customizes

The file holds **only customizations** — settings that match Ghostty's defaults are intentionally absent. Two clusters are kept explicit even though they happen to equal the current defaults; see "Defensive locks" below.

| Block             | What it does |
|-------------------|---------------|
| Theme             | `Catppuccin Macchiato`. |
| Typography        | `CaskaydiaMono Nerd Font Mono` 15 pt, thickened (strength 100), underline offset +1, cell height +5 % for breathing room. |
| Appearance        | 96 % opacity + background blur. Solid block cursor (non-blinking) in `#8aadf4`. Dimmed inactive splits (`0.85` opacity, `#1e2030` fill). Mouse cursor hides while typing. |
| Clipboard         | `copy-on-select = clipboard`. Right-click copies selection or pastes if none. External paste prompts for permission. |
| Window            | 140 × 38 default size. 10 px padding, balanced. Step-resize on. State saved across launches. `display-p3` color space for accurate theme colors on modern Macs. **`confirm-close-surface = false`** — see warning below. |
| Shell             | zsh integration with `cursor,sudo,title,ssh-env,ssh-terminfo,path` features. |
| Quick terminal    | `super+ctrl+space` drop-down, 34 % screen height, 0.18 s animation. |
| macOS             | Left-option acts as Alt. Auto secure-input on password prompts with indicator. Non-native fullscreen keeps the menu bar visible. |

## Defensive locks

Three blocks are kept explicit even though their values match current Ghostty defaults — they pin behavior so a future upstream default change can't loosen them silently:

- **Clipboard** — `clipboard-read = ask`, `clipboard-write = allow`. If a future Ghostty version flipped these to be more permissive, you'd want to know about it.
- **macOS security** — `macos-auto-secure-input = true`, `macos-secure-input-indication = true`. Same reasoning for the lock icon and password-prompt protection.
- **Keybinds** — every `keybind = …` line in `config` currently matches a Ghostty default. They're kept declared so an upstream rebind (e.g. `super+1` reassigned away from `goto_tab:1`) can't move muscle-memory keys without you noticing. Confirm the live set with `ghostty +list-keybinds`.

Don't strip these as "redundant defaults" — they earn their lines.

## Notable non-default choices

- **`confirm-close-surface = false`** — `super+w` (or `super+shift+w` for tabs) closes immediately with no prompt. Faster but easier to misfire when working with splits.
- **`copy-on-select = clipboard`** — selections go straight to the system clipboard. Default `true` means "yes, copy" with platform-specific destination; specifying `clipboard` is explicit on macOS.
- **`right-click-action = copy-or-paste`** — replaces Ghostty's default context menu. Right-click copies if there's a selection, otherwise pastes.
- **`window-save-state = always`** — keeps tabs/splits across app restarts (default is `default` which only saves on graceful quit).
- **`macos-non-native-fullscreen = visible-menu`** — non-native fullscreen but with the menu bar visible. Default is `false` (fully native).

## Keybinds

Super = Cmd. Listed bindings combine defaults inherited from Ghostty with overrides defined in `config`. Run `ghostty +list-keybinds` to see the full effective set on your install.

### Global

| Keys                | Action                              | Source  |
|---------------------|-------------------------------------|---------|
| `super+ctrl+space`  | Toggle quick terminal               | config  |
| `super+shift+r`     | Reload config                       | config  |
| `super+comma`       | Open config file in editor          | config  |
| `super+k`           | Clear screen                        | config  |
| `super+c` / `super+v` | Copy / paste                      | default |

### Splits

| Keys                  | Action                             | Source  |
|-----------------------|------------------------------------|---------|
| `super+d`             | Split right                        | config  |
| `super+shift+d`       | Split down                         | config  |
| `super+shift+h/j/k/l` | Focus split left / down / up / right | config |
| `super+shift+z`       | Zoom / unzoom current split        | config  |

### Tabs

| Keys                  | Action                             | Source  |
|-----------------------|------------------------------------|---------|
| `super+t`             | New tab                            | default |
| `super+w`             | Close surface (split or tab)       | default |
| `super+shift+w`       | Close whole tab                    | config  |
| `super+shift+]` / `[` | Next / previous tab                | config  |
| `super+1..9`          | Jump directly to tab N             | config  |

### Font size

| Keys        | Action              | Source  |
|-------------|---------------------|---------|
| `super+=`   | Increase font size  | config  |
| `super+-`   | Decrease font size  | config  |
| `super+0`   | Reset font size     | default |

## Machine-local overrides

The last line of `config` is `config-file = ?config.local`. The `?` makes the import optional — no error if the file is absent. Create `~/.config/ghostty/config.local` on any machine that wants a different font size, theme, opacity, etc., without editing the shared config:

```ini
# ~/.config/ghostty/config.local
font-size = 17
background-opacity = 1.0
```

Reload with `super+shift+r`.

## Troubleshooting

- **Keybind didn't take effect:** reload with `super+shift+r`. Run `ghostty +list-keybinds` to confirm what's actually bound, and `ghostty +validate-config --config-file=~/.config/ghostty/config` to catch syntax errors.
- **Colors washed out inside tmux or nvim:** their terminfo must advertise RGB. The tmux config in this repo already sets `terminal-features ",*:RGB"`.
- **Secure input stuck on:** the titlebar lock icon means a process requested it (typically a password prompt). Ghostty drops it automatically when the prompt completes; force a reset with `super+shift+r`.
- **Pasted long text mangles the prompt:** zsh's `bracketed-paste-magic` (configured in `zsh/.zshrc`) handles this; if a TUI strips bracketed paste, prefer `pbpaste | program` over Cmd-V.
- **Quick terminal won't pop:** the `toggle_quick_terminal` action requires a key bound to it (it is — `super+ctrl+space`). Hold the bind down — single tap toggles, doesn't sticky.
