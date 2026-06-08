# Fastfetch

**Fastfetch** is the program that prints a system-info summary next to an ASCII/
image logo — the thing you see in screenshots showing OS, kernel, CPU, RAM,
uptime, etc. It's the fast, actively-maintained successor to `neofetch`. Purely
cosmetic/informational; run it whenever you want a snapshot of the machine.

- **Live path:** `~/.config/fastfetch` → symlink → `fastfetch/` (this dir)
- **Editing `config.jsonc` here edits the live config.** Changes apply on the
  next `fastfetch` run — there's nothing to reload.
- Run it: just type `fastfetch`. Some shells run it on login (check your shell rc).

This config is an **Omarchy-flavoured** layout: an Arch logo on the left, and a
three-box info panel (Hardware / Software / Age·Uptime·Update) drawn with
box-drawing characters and Nerd Font icons.

## How a fastfetch config works

The whole file is one JSON object with two parts: a `logo` and an ordered
`modules` array. Fastfetch walks the array top-to-bottom and prints one line per
module. Special entries:

- `"break"` — a blank spacer line.
- `{ "type": "custom", "format": "…" }` — prints arbitrary text (used here for the
  box borders).
- `{ "type": "command", … }` — runs a shell command and prints its output (used
  for the Omarchy-specific values fastfetch doesn't know natively).
- Every other `type` (`cpu`, `gpu`, `memory`, `kernel`, …) is a built-in probe.

Each real module takes a `key` (the label on the left, often a Nerd Font icon)
and a `keyColor`. The tree-branch look (`│ ├`, `└ └`) is just clever `key`
strings — fastfetch isn't drawing a real tree, the characters in the keys line up
to *look* like one.

---

## Walkthrough

### Logo

```jsonc
"logo": {
  "type": "builtin",
  "source": "arch",
  "padding": { "top": 2, "right": 6, "left": 2 }
}
```

Use fastfetch's built-in **Arch** ASCII art, with padding so the info panel sits
a few columns to the right and a couple of rows down.

### Hardware box

```jsonc
{ "type": "custom", "format": "[90m┌──────────────────────Hardware──────────────────────┐" },
{ "type": "host",   "key": " PC",   "keyColor": "green" },
{ "type": "cpu",    "key": "│ ├",   "showPeCoreCount": true, "keyColor": "green" },
{ "type": "gpu",    "key": "│ ├",   "detectionMethod": "pci", "keyColor": "green" },
{ "type": "display","key": "│ ├󱄄",  "keyColor": "green" },
{ "type": "disk",   "key": "│ ├󰋊",  "keyColor": "green" },
{ "type": "memory", "key": "│ ├",   "keyColor": "green" },
{ "type": "swap",   "key": "└ └󰓡 ", "keyColor": "green" },
{ "type": "custom", "format": "[90m└────────────────────────────────────────────────────┘" },
```

- The two `custom` lines are the **top and bottom border** of the box.
  `[90m` is the ANSI escape for **bright-black (grey)**, so the borders are
  dim. (`` = ESC; `[90m` = "set foreground to bright black".)
- `host` = machine model. `cpu` with `showPeCoreCount` breaks out
  Performance/Efficiency core counts on hybrid CPUs. `gpu` with
  `detectionMethod: "pci"` reads the GPU from the PCI bus (reliable on Linux).
  `display`, `disk`, `memory`, `swap` are self-explanatory probes.
- All keyed green, with the `│ ├` / `└ └` prefixes forming the tree under `PC`.

### Software box

```jsonc
{ "type": "custom",  "format": "…Software…" },
{ "type": "command", "key": " OS", "keyColor": "blue",
  "text": "version=$(omarchy-version); echo \"Omarchy $version\"" },
{ "type": "command", "key": "│ ├󰘬", "text": "branch=$(omarchy-version-branch); echo \"$branch\"" },
{ "type": "command", "key": "│ ├󰔫", "text": "channel=$(omarchy-version-channel); echo \"$channel\"" },
{ "type": "kernel",  "key": "│ ├" },
{ "type": "wm",      "key": "│ ├" },
{ "type": "de",      "key": " DE" },
{ "type": "terminal","key": "│ ├" },
{ "type": "packages","key": "│ ├󰏖" },
{ "type": "wmtheme", "key": "│ ├󰉼" },
{ "type": "command", "key": "│ ├󰸌", "text": "theme=$(omarchy-theme-current); echo -e \"$theme …colour dots…\"" },
{ "type": "terminalfont", "key": "└ └" },
{ "type": "custom",  "format": "…box bottom…" },
```

The blue box. Note the mix:

- **`command` modules** call Omarchy helper scripts to print things fastfetch
  can't know: the Omarchy version/branch/release-channel, and the current theme
  name. The theme line additionally `echo -e`s a row of ANSI-coloured `●` dots as
  a palette swatch.
- **Built-ins** fill in `kernel`, `wm` (Hyprland), `de`, `terminal`,
  `packages` (count of installed packages), `wmtheme`, `terminalfont`.
- `` in the OS key is the Omarchy logo glyph from a Nerd/private font.

### Age / Uptime / Update box

```jsonc
{ "type": "custom",  "format": "…Age / Uptime / Update…" },
{ "type": "command", "key": "󱦟 OS Age", "keyColor": "magenta",
  "text": "echo $(( ($(date +%s) - $(stat -c %W /)) / 86400 )) days" },
{ "type": "uptime",  "key": "󱫐 Uptime", "keyColor": "magenta" },
{ "type": "command", "key": " Update", "keyColor": "magenta",
  "text": "updated=$(omarchy-version-pkgs); echo \"$updated\"" },
{ "type": "custom",  "format": "…box bottom…" },
"break"
```

- **OS Age** is a neat trick: `stat -c %W /` is the *birth time* (creation
  timestamp) of the root filesystem in epoch seconds; subtract it from `date +%s`
  (now) and divide by `86400` (seconds per day) → how many days ago you installed
  the system.
- `uptime` is the built-in "time since boot."
- **Update** runs `omarchy-version-pkgs` to report package-update status.

---

## Customising

- **Reorder / remove a line:** edit the `modules` array. Order in the file = order
  on screen.
- **Change the logo:** `"source": "arch"` → any name from `fastfetch --list-logos`,
  or point `"type": "file"` / `"image"` at your own.
- **Recolor a box:** the `keyColor` values (`green`/`blue`/`magenta`) set the label
  colour; the grey borders are the `[90m` escapes in the `custom` lines.
- **The icons** (`󰋊`, `󰓡`, `󱦟`, …) require a Nerd Font in your terminal — they're
  glyphs, not emoji.

## Validate after editing

```bash
# Render with no logo to /dev/null — any JSON/format error prints to stderr:
fastfetch -c ~/.config/fastfetch/config.jsonc --logo none >/dev/null && echo OK
```

## Reference

- Config schema & all module options: <https://github.com/fastfetch-cli/fastfetch/wiki/Configuration>
- List built-in modules: `fastfetch --list-modules`
