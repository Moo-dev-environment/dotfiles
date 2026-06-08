# Hyprland (hypr)

**Hyprland** is the Wayland **compositor** — the program that draws windows,
tiles them automatically, handles your keyboard/mouse/touchpad, manages monitors,
and runs the lock screen / idle behaviour. It *is* the desktop. On Omarchy,
Hyprland ships with a large set of sensible defaults; the files in this directory
are your **personal overrides on top of those defaults**.

- **Live path:** `~/.config/hypr` → symlink → `hypr/` (this dir)
- **Editing here edits the live desktop.** Apply most changes with
  `hyprctl reload` (re-reads all config). Some things (monitor/env changes) want
  a logout.
- Config language is Hyprland's own `key = value` format with `section { … }`
  blocks and `source = …` includes.

## The Omarchy layering model (important)

`hyprland.conf` is the **entry point**. It first sources Omarchy's defaults
(from `~/.local/share/omarchy/default/hypr/…`), then sources *your* files in this
directory. Because later `source` lines override earlier ones, **your files win**
over the defaults. So:

- To change a default → set it again in the matching file here.
- Never edit the files under `~/.local/share/omarchy/` — they're replaced on
  Omarchy updates. Override here instead.

The eight default sources + the theme + your five overrides are listed at the top
of `hyprland.conf` (below).

---

## File map

| File | Purpose |
|---|---|
| `hyprland.conf` | **entry point** — sources everything, in order |
| `monitors.conf` | display resolution / scale / arrangement |
| `input.conf` | keyboard, mouse, touchpad behaviour |
| `bindings.conf` | your application keyboard shortcuts |
| `looknfeel.conf` | gaps, borders, rounding, animations (all commented placeholders) |
| `autostart.conf` | programs to launch on login (currently none) |
| `hypridle.conf` | idle timeouts → screensaver / lock / suspend |
| `hyprlock.conf` | the lock screen's appearance & auth |
| `hyprsunset.conf` | blue-light / night-light behaviour |
| `xdph.conf` | screen-sharing portal (screencast picker) |

> `hypridle.conf`, `hyprlock.conf`, `hyprsunset.conf`, `xdph.conf` configure
> **companion daemons** (`hypridle`, `hyprlock`, `hyprsunset`,
> `xdg-desktop-portal-hyprland`) — separate programs in the Hypr ecosystem, not
> the compositor itself, but they read config from this directory.

---

## `hyprland.conf` — the entry point

```bash
# Omarchy defaults — sourced first, then overridden by your files below
source = ~/.local/share/omarchy/default/hypr/autostart.conf
source = ~/.local/share/omarchy/default/hypr/bindings/media.conf
source = ~/.local/share/omarchy/default/hypr/bindings/clipboard.conf
source = ~/.local/share/omarchy/default/hypr/bindings/tiling-v2.conf
source = ~/.local/share/omarchy/default/hypr/bindings/utilities.conf
source = ~/.local/share/omarchy/default/hypr/envs.conf
source = ~/.local/share/omarchy/default/hypr/looknfeel.conf
source = ~/.local/share/omarchy/default/hypr/input.conf
source = ~/.local/share/omarchy/default/hypr/windows.conf
source = ~/.config/omarchy/current/theme/hyprland.conf      # active theme's window colours

# Your overrides (win over the defaults above)
source = ~/.config/hypr/monitors.conf
source = ~/.config/hypr/input.conf
source = ~/.config/hypr/bindings.conf
source = ~/.config/hypr/looknfeel.conf
source = ~/.config/hypr/autostart.conf

# Dynamic feature toggles written by Omarchy menu actions
source = ~/.local/state/omarchy/toggles/hypr/*.conf
```

Order is everything: defaults → theme → your overrides → runtime toggles. The
defaults provide all the **standard keybindings** (window movement, media keys,
clipboard, screenshots) — those live in Omarchy's `bindings/*.conf`, which is why
this repo's `bindings.conf` only contains *app-launch* shortcuts (it doesn't need
to redefine window management). The `toggles/*.conf` glob lets the Omarchy menu
flip features on/off by dropping tiny config files in a state directory.

---

## `monitors.conf` — displays

```bash
env = GDK_SCALE,2
monitor=,preferred,auto,auto
```

- `env = GDK_SCALE,2` — tells GTK apps to render at **2× scale** (HiDPI / retina).
  Tuned for high-density panels; the file's comments give alternative values
  (`1.75`, `1`) for 4K-fractional or 1080p/1440p/ultrawide displays.
- `monitor = , preferred, auto, auto` — the catch-all monitor rule. The fields are
  `name, resolution, position, scale`:
  - empty name (`,`) = "any/all monitors"
  - `preferred` = use the display's native/best mode
  - `position auto` = let Hyprland place it
  - `scale auto` = pick a sensible scale
  
  Everything else in the file is **commented examples** for specific setups
  (rotated secondary monitor via `transform`, external 6K display, disabling a
  ghost monitor, etc.) — uncomment and edit if you add hardware.

---

## `input.conf` — keyboard, mouse, touchpad

```bash
input {
  kb_layout = us
  kb_options = compose:caps      # Caps Lock becomes the Compose key (for é, ñ, …)
  repeat_rate = 40               # key auto-repeat speed (chars/sec) while held
  repeat_delay = 250             # ms before auto-repeat kicks in
  numlock_by_default = true      # start with NumLock on
  touchpad {
    clickfinger_behavior = true  # 2-finger tap/click = right-click (vs corner zones)
    scroll_factor = 0.4          # slow down touchpad scrolling to 40%
  }
}
```

- `kb_layout = us` with `kb_options = compose:caps` — US layout, and **Caps Lock
  is repurposed as a Compose key** so you can type accented/special characters
  (Compose + ' + e → é). The commented lines show how to add multiple layouts and
  toggle between them.
- `repeat_rate` / `repeat_delay` make held keys repeat fast (40/s) but not too
  eagerly (250ms grace) — good for Vim-style navigation.
- Touchpad: `clickfinger_behavior` means a two-finger press is right-click (modern
  laptop behaviour), and `scroll_factor = 0.4` tames over-fast scrolling.

```bash
windowrule = match:class (Alacritty|kitty|foot), scroll_touchpad 1.5
windowrule = match:class com.mitchellh.ghostty, scroll_touchpad 0.2
```

Per-application **window rules** adjusting touchpad scroll speed inside specific
terminals (terminals don't have smooth pixel scrolling, so the multiplier is
tuned per app — faster for Alacritty/kitty/foot, much slower for Ghostty). The
rest of the file is commented gesture examples (3-finger workspace swipes, etc.).

---

## `bindings.conf` — your app shortcuts

This file only defines **application launchers** — window/tiling/media bindings
come from the Omarchy defaults. Syntax: `bindd = MODS, KEY, Description, dispatcher, args`
(the extra `d` in `bindd` attaches the human-readable *Description* that shows up
in the keybind cheat-sheet).

```bash
bindd = SUPER, RETURN, Terminal, exec, uwsm-app -- xdg-terminal-exec --dir="$(omarchy-cmd-terminal-cwd)"
bindd = SUPER ALT, RETURN, Tmux, exec, … xdg-terminal-exec … bash -c "tmux attach || tmux new -s Work"
bindd = SUPER SHIFT, RETURN, Browser, exec, omarchy-launch-browser
```

- `SUPER` is the Windows/Cmd key. `SUPER+Enter` opens a terminal **in the current
  directory** (`omarchy-cmd-terminal-cwd` figures out the focused window's cwd).
- `SUPER+ALT+Enter` opens a terminal that **attaches to (or creates) a tmux session
  named `Work`** — your persistent workspace. This is the tmux entry point.
- `uwsm-app --` launches the app under **uwsm** (a session manager) so it's
  tracked properly by the systemd user session.

The rest are mnemonic `SUPER+SHIFT+<letter>` launchers, e.g.:

| Shortcut | Opens |
|---|---|
| `SUPER+SHIFT+F` | File manager (Nautilus) |
| `SUPER+SHIFT+B` | Browser |
| `SUPER+SHIFT+M` | Music (Spotify) / `+ALT` Music TUI (cliamp) |
| `SUPER+SHIFT+N` | Editor |
| `SUPER+SHIFT+D` | Docker TUI (lazydocker) |
| `SUPER+SHIFT+G` | Signal / `+ALT` WhatsApp / `+CTRL` Google Messages |
| `SUPER+SHIFT+O` | Obsidian |
| `SUPER+SHIFT+W` | Typora |
| `SUPER+SHIFT+/` | 1Password |
| `SUPER+SHIFT+A` | ChatGPT (web app) / `+ALT` Grok |
| `SUPER+SHIFT+C/E/Y/P/X` | Calendar / Email / YouTube / Google Photos / X |

`omarchy-launch-webapp` opens a URL as a standalone PWA-style window;
`omarchy-launch-or-focus` raises the app if it's already running instead of
opening a duplicate. The file ends with **commented templates** showing how to add
your own bindings, override existing ones (`unbind` then `bindd`), or map special
keyboard buttons.

> Tip: a literal `#` in a web-app URL must be typed as `##`, because Hyprland
> treats `#` as a comment (noted in the file).

---

## `looknfeel.conf` — visual feel

Entirely **commented placeholders** — this file is a menu of the most common
tweaks, all disabled so Omarchy's defaults apply. Uncomment to change:

```bash
general    { gaps_in / gaps_out / border_size / layout }   # spacing & border thickness
decoration { rounding / dim_inactive / dim_strength }       # corner radius, dim unfocused windows
animations { enabled }                                      # turn animations off
layout     { single_window_aspect_ratio }                   # avoid ultra-wide single windows
scrolling  { column_width }                                 # for the niri-like scrolling layout
```

Each has a wiki link inline. Leave it as-is unless you want to deviate from the
Omarchy look.

---

## `autostart.conf` — login programs

```bash
# Extra autostart processes
# exec-once = uwsm-app -- my-service
```

Empty but for a commented example. `exec-once` runs a command **once** when
Hyprland starts. Add background services / tray apps here. (Omarchy's own
autostart is in its defaults; this is for *your* additions.)

---

## `hypridle.conf` — idle behaviour

Controls what happens when you stop touching the machine. Read by the `hypridle`
daemon.

```bash
general {
    lock_cmd = omarchy-system-lock
    before_sleep_cmd = OMARCHY_LOCK_ONLY=true omarchy-system-lock
    after_sleep_cmd = sleep 1 && omarchy-system-wake
    inhibit_sleep = 3
}
```

- `lock_cmd` — how to lock (Omarchy's helper, which also locks 1Password).
- `before_sleep_cmd` — lock **before** the system suspends, so you wake to a lock
  screen. `OMARCHY_LOCK_ONLY=true` locks without also scheduling the display off.
- `after_sleep_cmd` — on wake, wait 1s (for PAM/auth readiness) then re-enable the
  display.
- `inhibit_sleep = 3` — don't actually suspend until the lock has engaged.

```bash
listener { timeout = 300; on-timeout = pidof hyprlock || omarchy-launch-screensaver }
listener { timeout = 302; on-timeout = omarchy-system-lock; on-resume = omarchy-system-wake }
```

Two staged `listener`s (timeouts in **seconds**):

- At **5 min** (300s) idle → start the screensaver, *unless* hyprlock is already
  running (`pidof hyprlock || …` skips it if locked).
- At **~5 min 2s** (302s) → fully lock the system; `on-resume` wakes the display
  when you return. The 2-second offset exists because the screensaver resets the
  idle timer, so the lock is timed as "half the intended 10-minute window + a 2s
  margin" (explained in the file's comment).

---

## `hyprlock.conf` — the lock screen

Appearance and authentication for `hyprlock` (the lock screen program).

```bash
source = ~/.config/omarchy/current/theme/hyprlock.conf   # theme-provided colours ($color, $inner_color, …)

general { ignore_empty_input = true }                    # don't try to auth on an empty password
background {
    color = $color
    path = ~/.config/omarchy/current/background           # the wallpaper, also used on the lock screen
    blur_passes = 3                                        # blur it 3× for a frosted look
}
animations { enabled = false }                            # instant, no fade
input-field {
    size = 650, 100; position = 0, 0; halign = center; valign = center   # big centered password box
    inner_color = $inner_color; outer_color = $outer_color; outline_thickness = 4
    font_family = CaskaydiaMono Nerd Font Mono; font_color = $font_color
    placeholder_text = Enter Password
    fail_text = <i>$FAIL ($ATTEMPTS)</i>                  # shows the failure reason + attempt count
    rounding = 0                                          # square box
}
auth { fingerprint:enabled = false }                      # password only, no fingerprint
```

Colours come from the theme via the `$…` variables (so the lock screen matches
your current theme); the wallpaper is reused and blurred. `$FAIL`/`$ATTEMPTS` are
hyprlock variables substituted at runtime.

---

## `hyprsunset.conf` — night light

```bash
profile {
    time = 07:00
    identity = true        # "identity" = no colour change; leave the screen untinted
}
```

`hyprsunset` can warm the screen colour temperature in the evening (like f.lux /
Night Shift). This config **disables that** by defining a single `identity`
profile — without it, Omarchy's default applies a tint. The commented block shows
how to opt in: add `exec-once = uwsm app -- hyprsunset` to autostart and a second
`profile` with a `temperature` (e.g. 4000K at 20:00).

---

## `xdph.conf` — screen sharing

```bash
screencopy {
    allow_token_by_default = true
    custom_picker_binary = hyprland-preview-share-picker
}
```

Configures `xdg-desktop-portal-hyprland` — the bridge that lets apps (browsers,
OBS, video calls) capture your screen on Wayland.

- `allow_token_by_default = true` — remember screen-share permission so apps don't
  re-prompt every time (a "restore token").
- `custom_picker_binary` — use Hyprland's nicer share-picker UI (with live
  previews) when you choose which window/monitor to share.

---

## Best use cases / workflow

- **Add an app shortcut:** add a `bindd` line to `bindings.conf`, then
  `hyprctl reload`.
- **Fix display scaling:** edit the `monitor=` / `GDK_SCALE` lines in
  `monitors.conf` (logout to be safe).
- **Change idle/lock timing:** edit the `timeout` values in `hypridle.conf`.
- **Tweak the look:** uncomment the relevant block in `looknfeel.conf`.
- **See all active bindings** (defaults + yours): `SUPER` opens Omarchy's keybind
  cheat-sheet, or run `hyprctl binds`.

## Validate after editing

```bash
# Parse the whole config tree and report errors WITHOUT launching a session:
Hyprland --verify-config        # prints "config ok" on success

# Apply changes to the running session:
hyprctl reload
```

## Reference

- Hyprland wiki (every variable & dispatcher): <https://wiki.hypr.land/>
- Companion daemons: hypridle, hyprlock, hyprsunset docs on the same wiki.
