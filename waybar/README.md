# Waybar

**Waybar** is the status bar across the top of the screen on Wayland desktops
(here, Hyprland under Omarchy). It's a row of *modules* — workspaces, clock,
network, battery, tray, plus custom Omarchy widgets — laid out in three groups
(left / center / right). Two files drive it:

- `config.jsonc` — **what** modules exist, where they sit, and how each behaves
  (format strings, click actions, refresh intervals).
- `style.css` — **how** it looks (colours, spacing, fonts). GTK CSS.

Files:

- **Live path:** `~/.config/waybar` → symlink → `waybar/` (this dir)
- **Editing here edits the live bar.** `config.jsonc` has
  `"reload_style_on_change": true`, so CSS edits apply instantly; structural
  changes to `config.jsonc` need a bar restart (`omarchy-restart-waybar`, or
  `killall waybar && waybar &`).

> The `.jsonc` extension means **JSON with Comments** — you can put `//` comments
> in it, unlike strict JSON.

---

## `config.jsonc` — behaviour

### Bar-level settings

```jsonc
"reload_style_on_change": true,   // watch style.css and re-apply on save
"layer": "top",                   // draw above normal windows (the compositor layer)
"position": "top",                // dock at the top of the screen
"spacing": 0,                     // 0px default gap between modules (spacing is done in CSS)
"height": 26,                     // bar height in pixels
```

### Module placement

```jsonc
"modules-left":   ["custom/omarchy", "hyprland/workspaces"],
"modules-center": ["clock", "custom/weather", "custom/update", "custom/voxtype",
                   "custom/screenrecording-indicator", "custom/idle-indicator",
                   "custom/notification-silencing-indicator"],
"modules-right":  ["group/tray-expander", "bluetooth", "network", "pulseaudio", "cpu", "battery"],
```

Three ordered lists decide what appears and in what order within each third of
the bar. A name like `hyprland/workspaces` is a **built-in** module; `custom/…`
is a script-backed module defined later in the file; `group/…` is a container
that bundles several modules.

### `hyprland/workspaces` — the workspace switcher

```jsonc
"on-click": "activate",            // click a workspace number → switch to it
"format": "{icon}",                // render each workspace as its icon (below)
"format-icons": { "1": "1", … "10": "0", "active": "󱓻" },
"persistent-workspaces": { "1": [], "2": [], "3": [], "4": [], "5": [] }
```

- `format-icons` maps each workspace to a label — here just the digit, except the
  currently-focused one shows a dot glyph `󱓻` (`"active"`).
- `persistent-workspaces` forces workspaces 1–5 to **always** show even when
  empty (the `[]` means "on all monitors"), so the bar layout doesn't jump around
  as you open/close apps.

### `custom/omarchy` — the menu button (far left)

```jsonc
"format": "<span font='omarchy'></span>",   // the Omarchy logo glyph from a private font
"on-click": "omarchy-menu",                        // left-click → open the Omarchy menu
"on-click-right": "xdg-terminal-exec",             // right-click → open a terminal
"tooltip-format": "Omarchy Menu\n\nSuper + Alt + Space"
```

The `<span>` is Pango markup — it forces a specific font (`omarchy`) just for that
one glyph so the logo renders regardless of the bar's default font.

### `custom/update` — update-available indicator

```jsonc
"format": "",                                       // icon (empty = no badge when nothing to show)
"exec": "omarchy-update-available",                  // script whose output becomes the module text
"on-click": "omarchy-launch-floating-terminal-with-presentation omarchy-update",
"signal": 7,                                         // can be force-refreshed via SIGRTMIN+7
"interval": 21600                                    // otherwise re-check every 6 hours (21600s)
```

Pattern for **custom modules**: `exec` is a command Waybar runs; its stdout is
shown. `interval` is how often it re-runs. `signal` lets another program poke
this module to refresh immediately (`pkill -RTMIN+7 waybar`).

### `cpu`

```jsonc
"interval": 5,
"format": "󰍛",
"on-click": "omarchy-launch-or-focus-tui btop",      // click → open btop (system monitor)
"on-click-right": "alacritty"                         // right-click → open Alacritty
```

### `clock` — date/time (center)

```jsonc
"format": "{:L%d %b %Y | %A | %I:%M %p}",   // e.g. "08 Jun 2026 | Monday | 03:14 PM"
"tooltip-format": "<tt><small>{calendar}</small></tt>",
"calendar": { "mode": "month", "on-scroll": 1, "format": { "today": "<b><u>{}</u></b>" } },
"actions": { "on-scroll-up": "shift_up", "on-scroll-down": "shift_down" },
"on-click-right": "omarchy-launch-floating-terminal-with-presentation omarchy-tz-select"
```

The `format` is the important line — a strftime pattern wrapped in Waybar's
`{:...}` time syntax. `%L` requests locale-aware formatting. Decoded:
`%d`=day-of-month, `%b`=short month, `%Y`=4-digit year, `%A`=full weekday,
`%I`=12-hour hour, `%M`=minute, `%p`=AM/PM. Hovering shows a monthly calendar
(today bold+underlined); scrolling over the clock pages through months.

### `network`

```jsonc
"format-icons": ["󰤯", "󰤟", "󰤢", "󰤥", "󰤨"],   // signal strength ramp, weakest → strongest
"format-wifi": "{icon}",
"format-ethernet": "󰀂",
"format-disconnected": "󰤮",
"tooltip-format-wifi": "{essid} ({frequency} GHz)",
"interval": 3,
"on-click": "omarchy-launch-wifi"                  // click → wifi menu
```

Waybar picks the icon from `format-icons` by signal strength; tooltip shows the
network name and band. Different `format-*` keys cover wifi / wired /
disconnected states.

### `battery`

```jsonc
"format": "{capacity}% {icon}",
"format-icons": { "charging": [10 glyphs], "default": [10 glyphs] },
"format-full": "󰂅",
"tooltip-format-discharging": "{power:>1.0f}W↓ {capacity}%",
"states": { "warning": 20, "critical": 10 }
```

- The two 10-glyph arrays are battery-fill icons; Waybar indexes into them by
  charge level (so the icon visibly drains), with a separate set while charging.
- `tooltip-format-*` shows live power draw in watts plus the percentage.
- `states` adds CSS classes at thresholds: at ≤20% the module gets
  `.warning`, at ≤10% `.critical` — themes colour these (often amber/red).

### `bluetooth`, `pulseaudio`

Same pattern: an icon per state (`format-off`, `format-connected`, `format-muted`,
…), a tooltip, and click actions wired to Omarchy helper scripts
(`omarchy-launch-bluetooth`, `omarchy-launch-audio`). `pulseaudio` also has
`"scroll-step": 5` so scrolling over it changes volume by 5%, and right-click
(`pamixer -t`) toggles mute.

### `group/tray-expander` — collapsible system tray

```jsonc
"orientation": "inherit",
"drawer": { "transition-duration": 600, "children-class": "tray-group-item" },
"modules": ["custom/expand-icon", "tray"]
```

A **group** with a `drawer`: normally just the expand chevron
(`custom/expand-icon`) shows; hovering slides the actual system tray open over
600ms. Keeps idle tray icons hidden.

### Indicator modules

`custom/screenrecording-indicator`, `custom/idle-indicator`,
`custom/notification-silencing-indicator`, `custom/voxtype` all follow the custom
pattern: a script with `"return-type": "json"` (so the script can return text +
a CSS class + a tooltip together), refreshed on a `signal`, with click actions to
toggle the underlying state. They only light up (gain an `.active` /`.recording`
class) when that thing is happening — screen recording in progress, idle inhibited,
notifications silenced, voice-typing recording.

### `tray`

```jsonc
"icon-size": 12,
"spacing": 17
```

Plain system tray (the icons apps put in the bar). 12px icons, 17px apart.

---

## `style.css` — appearance

```css
@import "../omarchy/current/theme/waybar.css";
```

**The theme link.** This relative path resolves (lexically, through the symlink)
to `~/.config/omarchy/current/theme/waybar.css`, which defines `@background`,
`@foreground`, etc. for the active Omarchy theme. Switching themes rewrites that
file and the bar restyles. *This is why the whole `waybar/` directory is
symlinked as a unit* — the relative import has to keep resolving.

```css
* {
  background-color: @background;   /* theme-provided colour variables */
  color: @foreground;
  border: none;
  border-radius: 0;                /* square corners */
  min-height: 0;                   /* let modules shrink to content */
  font-family: 'CaskaydiaMono Nerd Font Mono';
  font-size: 12px;
}
```

The universal selector sets the baseline: theme colours, no borders, the Nerd
Font (needed for all those glyphs), 12px text.

The remaining rules are **per-module spacing**, addressed by `#id` selectors
(`#cpu`, `#battery`, `#clock`, …). They set `margin`/`min-width`/`padding` to
fine-tune the gaps between widgets — e.g.:

```css
#workspaces button { all: initial; padding: 0 6px; margin: 0 1.5px; min-width: 9px; }
#workspaces button.empty { opacity: 0.5; }        /* dim unused workspaces */
```

`all: initial` wipes GTK's default button styling so workspace numbers render
flat. `.empty` (a class Waybar adds to unused persistent workspaces) is faded to
50% so the active ones stand out.

State-class colours:

```css
#custom-screenrecording-indicator.active,
#custom-idle-indicator.active,
#custom-notification-silencing-indicator.active,
#custom-voxtype.recording { color: #a55555; }     /* muted red while active */
```

These are the only **hardcoded** colours — a muted red used to flag "something is
actively recording/inhibited." Everything else comes from the theme import.

---

## Best use cases / tips

- **Add a module:** define it (or reference a built-in) and add its name to one of
  the `modules-*` arrays. Restart the bar.
- **Tweak look only:** edit `style.css` — it hot-reloads, no restart.
- **Force a custom module to refresh now:** `pkill -RTMIN+<signal> waybar` using
  the module's `"signal"` number.
- **Debug a broken bar:** run `waybar` from a terminal (not via Omarchy) and read
  the parse errors it prints to stderr.

## Validate after editing

```bash
# Launch against these files for 3s; any parse error prints to stderr:
timeout 3 waybar -c ~/.config/waybar/config.jsonc -s ~/.config/waybar/style.css
```

## Reference

- Module list & options: <https://github.com/Alexays/Waybar/wiki/Configuration>
- Styling (GTK CSS): <https://github.com/Alexays/Waybar/wiki/Styling>
