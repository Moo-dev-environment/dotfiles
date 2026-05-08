# Starship Prompt

Reference for this Starship configuration — every module, its options, and the
reasoning behind the layout. The companion to `zsh/REFERENCE.md`.

- **Config file:** `~/.config/starship.toml` — symlinked to this repo at
  `starship/starship.toml`. Editing either is the same file.
- **Theme:** custom palette `midnight_horizon` (Tokyo Night–leaning).
- **Starship version target:** 1.16+ (uses `right_format`, vimcmd replace
  symbols, `up_to_date` git status, `repo_root_format`). Tested on 1.25.
- **Init:** loaded by `zsh/conf.d/07-prompt.zsh` via `eval "$(starship init zsh)"`.

## Table of Contents

- [Anatomy of the Prompt](#anatomy-of-the-prompt)
- [Top-Level Settings](#top-level-settings)
- [Palette](#palette)
- [Module Reference](#module-reference)
  - [Identity](#identity)
  - [Directory](#directory)
  - [Git](#git)
  - [Timing](#timing)
  - [Runtimes](#runtimes)
  - [Containers, Orchestration & Cloud](#containers-orchestration--cloud)
  - [Shell State](#shell-state)
  - [Environment](#environment)
  - [Character](#character)
- [Git Status Symbols](#git-status-symbols)
- [$status Signal Mapping](#status-signal-mapping)
- [Disabled by Default](#disabled-by-default)
- [Customization Recipes](#customization-recipes)
- [Troubleshooting](#troubleshooting)

---

## Anatomy of the Prompt

Two-line prompt. Line 1 is context (where am I?), line 2 is action (what
happened, where do I type?). Runtimes appear on the right of line 2 only when
the project actually uses them.

```
╭─ <sudo> <user> <host> 󰉋 ~/path/repo  branch sha state status  ╌╌  󱎫 1.2s
╰─ <shlvl> <docker> <k8s> <terraform> <aws> <gcloud> <jobs> <status> ❯       <python> <node> <bun> <deno> <go> <rust> <java> <lua> <ruby> <direnv>
                                                                  ↑               ↑
                                                       cursor goes here     right_format
```

**Line 1 (`format`)** — left to right:

`$sudo` → `$username` → `$hostname` → `$directory` → `$git_branch` →
`$git_commit` → `$git_state` → `$git_status` → `$fill` → `$cmd_duration`

`$fill` is what right-aligns `$cmd_duration` to the end of line 1. `$fill` uses
a space symbol (not the default `.`) so the gap is invisible.

**Line 2 (continuation of `format`)** — left to right:

`$shlvl` → `$docker_context` → `$kubernetes` → `$terraform` → `$aws` →
`$gcloud` → `$jobs` → `$status` → `$character`

Most of these are conditional — they render only when their context is active
(in a container, kube context set, AWS profile loaded, etc.).

**Right side (`right_format`)** — runtimes only:

`$python` → `$nodejs` → `$bun` → `$deno` → `$golang` → `$rust` → `$java` →
`$lua` → `$ruby` → `$direnv`

---

## Top-Level Settings

| Setting | Value | Why |
|---|---|---|
| `add_newline` | `false` | Keeps consecutive prompts tight; the box-drawing `╭─/╰─` already provides separation. |
| `command_timeout` | `1500` ms | Default is 500 ms. Bumped because `git status` on a slow filesystem (network share, FUSE mount) can blow past 500 ms and cause Starship to log a warning. |
| `continuation_prompt` | `[∙](fg:muted) ` | Shown when zsh wants more input (unclosed quote, backslash newline). Subdued so it doesn't look like a fresh prompt. |
| `palette` | `midnight_horizon` | Selects the named palette below. |

`scan_timeout` is intentionally **not** set — the default (30 ms) is correct;
setting it to the same value is just noise.

---

## Palette

Defined under `[palettes.midnight_horizon]`. Every module uses these names
instead of raw hex, so swapping the whole color scheme means editing one block.

| Name | Hex | Used For |
|---|---|---|
| `muted` | `#7f8ea3` | secondary text, sha, cmd_duration, jobs, shlvl |
| `surface2` | `#44506a` | the `╭─/╰─` corners |
| `blue` | `#82aaff` | directory, docker, lua |
| `teal` | `#86e1fc` | repo root, kubernetes, (time when enabled) |
| `green` | `#c3e88d` | success character, runtimes (python/node/go/rust/java/ruby) |
| `amber` | `#ffc777` | git_status, vimcmd, package, aws, direnv, read-only |
| `peach` | `#ff966c` | username, hostname, git_state, vimcmd replace |
| `red` | `#ff757f` | sudo, root, error character, status failures |
| `lavender` | `#c099ff` | git_branch, terraform, vimcmd visual |

To swap themes, define another `[palettes.<name>]` block and change the
top-level `palette = "..."` reference.

---

## Module Reference

### Identity

| Module | Renders when | Notes |
|---|---|---|
| `[username]` | Root, or over SSH | `show_always = false`. Local non-root: hidden. Root: bold red. SSH: peach. |
| `[hostname]` | SSH session only | `ssh_only = true`. Format `@host` so it concatenates after `$username`. |
| `[sudo]` | Sudo credential cached | Compact lock glyph in red — silent reminder you have elevated rights. |

### Directory

`[directory]` — the `🗂 ~/path` segment.

| Option | Value | Effect |
|---|---|---|
| `truncation_length` | `100` | Max parent directories shown. Set high to effectively disable truncation. **Important:** `0` would collapse to basename, the opposite of what you want. |
| `truncate_to_repo` | `false` | Don't trim everything before the git root — show the full path so the directory location is unambiguous. |
| `truncation_symbol` | `…/` | If truncation ever does kick in. |
| `home_symbol` | `~` | Standard. |
| `read_only` | ` 󰌾` | Padlock glyph appended when CWD isn't writable. |
| `format` | `[󰉋 $path](style)[$read_only]…` | Folder icon + path. |
| `repo_root_style` | `bold fg:teal` | The repo-root segment is highlighted distinctly. |
| `repo_root_format` | path-before-root in blue, repo root in teal, sub-path back in blue | Makes the "where does this project start?" boundary visible at a glance. |

`[directory.substitutions]` swaps common folder names for nerdfont icons:
`Documents` → 󰈙, `Downloads` → , `Music` → 󰝚, `Pictures` → ,
`Desktop` → , `Projects` → , `GITHUB` → .

### Git

Four modules cover git state, in this order on line 1:

#### `[git_branch]`

` main`. Lavender. Truncates branch names over 32 chars with `…`.

#### `[git_commit]`

Short SHA, only in detached-HEAD / rebase / bisect states (`only_detached =
true`). Tags **are** shown (`tag_disabled = false` — the default is `true`,
which would silently make `$tag` and `tag_symbol` no-ops).

```
[git_commit]
commit_hash_length = 7
only_detached      = true
tag_disabled       = false
tag_symbol         = " 󰓹 "
```

#### `[git_state]`

Renders during in-progress operations: REBASING 3/7, MERGING, CHERRY-PICKING,
BISECTING, REVERTING. Bold peach so it's impossible to miss.

#### `[git_status]`

The compact summary cluster. **Every symbol now includes `${count}`** — a repo
with 1 unstaged file looks distinctly different from one with 50.

See [Git Status Symbols](#git-status-symbols) below for the full legend.

### Timing

`[cmd_duration]` shows total wall time for any command that took **≥ 750 ms**.
Below that threshold, nothing renders — it's not noise for fast commands, just
a heads-up when something was slow.

`[time]` is **disabled** by default in this config. Reasoning: the macOS menu
bar and Ghostty title bar already show the clock, so a third copy in the prompt
adds nothing. The block is kept (with `disabled = true`) so re-enabling is one
line.

### Runtimes

All runtime modules render only when Starship detects relevant project files
(e.g., `package.json` for `nodejs`, `Cargo.toml` for `rust`, etc.). Default
detection is fine for most — only `[java]` is explicitly scoped, because Java
detection is expensive enough to matter.

| Module | Color | Notes |
|---|---|---|
| `[python]` | green | Uses mise — `pyenv_prefix` was dropped from the format. Shows venv in parens when active. |
| `[nodejs]` | green | Standard. |
| `[bun]` | green | 🥟 emoji as symbol (no good nerdfont glyph yet). |
| `[deno]` | green | Detects `deno.json` / `deno.jsonc`. |
| `[golang]` | green | Standard. |
| `[rust]` | green | Standard. |
| `[java]` | green | Scoped via `detect_extensions` and `detect_files` so it doesn't shell out to `java -version` outside Java/JVM projects. Detects Maven, Gradle, Leiningen, Boot, sbt. |
| `[lua]` | blue | Standard. |
| `[ruby]` | green | Standard. |

### Containers, Orchestration & Cloud

| Module | State | Why |
|---|---|---|
| `[docker_context]` | Active | Renders when a non-default Docker context is selected. |
| `[kubernetes]` | **Disabled** | Enable when actively shipping to k8s — otherwise it just clutters the prompt with a context name you ignore. |
| `[terraform]` | **Disabled** | Same reasoning. |
| `[aws]` | **Disabled** | Re-enable per workstation via `disabled = false` if you do AWS work. |
| `[gcloud]` | **Disabled** | Same. |

To enable any of these, flip `disabled = false` in the matching block.

### Shell State

#### `[jobs]`

Compact `✦ <count>` muted indicator when ≥ 1 backgrounded job exists.
`number_threshold = 1` — single-job threshold so you always see when you've
suspended something.

#### `[status]`

Renders the **non-zero** exit code of the last command. Three flags upgrade
this from a raw number to something readable:

```
map_symbol            = true   # exit 0–127 with documented meaning → its name
recognize_signal_code = true   # exit 128+N → "SIGNAME"
pipestatus            = true   # show every segment of a failed pipe
```

`130` becomes `INT`, `137` becomes `KILL`, `143` becomes `TERM`. A pipe like
`a | b | c` where `b` died with SIGINT renders as `[0|INT|0] => INT`. See
[$status Signal Mapping](#status-signal-mapping) for the full legend.

#### `[shlvl]`

Renders only when **`SHLVL >= 2`** — i.e., you've nested into another shell
(tmux pane, `nvim :term`, `mise shell`, a docker exec, etc.). `❯ <depth>` in
muted gray. Stays out of the way in normal shells.

### Environment

#### `[direnv]`

`󰇙 loaded/allowed` in amber when direnv is active in the current directory.
Useful for catching unexpected `.envrc` activations or the `block` state.

#### `[os]`

**Disabled.** Local work is always macOS; SSH context is already covered by
`$hostname`. Block kept for easy re-enable; symbols configured for Macos,
Linux, Arch, Ubuntu, Debian, Fedora.

#### `[battery]`

**Removed from `right_format`.** macOS menu bar already shows battery state.
Config kept (display thresholds for <50% amber, <20% bold red) so you can
restore by appending `$battery` back to `right_format`. Note: `[battery]`
doesn't accept a `disabled` field — the only way to hide it is to leave it out
of the format strings.

#### `[package]`

**Disabled.** Useful when actively publishing packages, just noise when
consuming. Re-enable with `disabled = false`.

### Character

The cursor prompt at the end of line 2. Communicates last command status and
zle keymap (vi mode):

| State | Symbol | Style |
|---|---|---|
| Last command succeeded | `❯` | bold green |
| Last command failed | `❯` | bold red |
| vi command (normal) mode | `❮` | bold amber |
| vi replace-one mode | `❮` | bold amber |
| vi replace mode | `❮` | bold peach |
| vi visual mode | `❮` | bold lavender |

The arrow direction flips in vi command mode — a subtle but unmissable cue
that you're not in insert mode anymore.

---

## Git Status Symbols

Order in the cluster: `[$all_status$ahead_behind]`. `all_status` expands to
conflicted → stashed → deleted → renamed → modified → staged → untracked, in
that order. Then `ahead_behind` adds the remote-divergence arrows.

| Symbol | Means | Example render |
|---|---|---|
| `~3` | conflicted (unresolved merge) | `~3 ` |
| `*2` | stashed entries | `*2 ` |
| `✘1` | staged for deletion | `✘1 ` |
| `»1` | renamed | `»1 ` |
| `!7` | modified, unstaged | `!7 ` |
| `+4` | staged changes | `+4 ` |
| `?12` | untracked | `?12 ` |
| `⇡2` | ahead of upstream by 2 | `⇡2 ` |
| `⇣1` | behind upstream by 1 | `⇣1 ` |
| `⇕⇡1⇣3` | diverged (1 ahead, 3 behind) | shown only when both apply |
| _empty_ | clean & up to date | nothing rendered (`up_to_date = ""`) |

Color: `fg:amber`. Counts use the `${count}` interpolation; the diverged
symbol uses `${ahead_count}` / `${behind_count}` separately.

---

## $status Signal Mapping

With `recognize_signal_code = true`, exit codes ≥ 128 are decoded as the
signal that killed the process (exit code = 128 + signal number). Common ones
on macOS:

| Exit code | Renders as | What happened |
|---|---|---|
| `130` | `✘INT` | Ctrl-C |
| `131` | `✘QUIT` | Ctrl-\ |
| `137` | `✘KILL` | OOM killer or `kill -9` |
| `139` | `✘SEGV` | Segfault |
| `141` | `✘PIPE` | Wrote to closed pipe |
| `143` | `✘TERM` | Polite kill |

With `map_symbol = true`, certain non-signal exit codes also get a name (e.g.,
`126` → `NOPERM`, `127` → `NOTFOUND`). For pipes, `pipestatus_format` shows
each segment's status before the trailing summary, separated by a muted `|`:

```
zsh% false | true | false   →   [✘1|0|✘1] => ✘1
```

---

## Disabled by Default

Quick reference for what's off and how to flip it on. Either toggle
`disabled = false` in the named block, or — for the four runtimes that aren't
in `format`/`right_format` — add the variable to that string.

| Module | How to enable |
|---|---|
| `[time]` | `disabled = false` **and** add `$time` to `format` |
| `[os]` | `disabled = false` **and** add `$os` to `right_format` |
| `[package]` | `disabled = false` **and** add `$package` to `right_format` |
| `[battery]` | Add `$battery` to `right_format` (no `disabled` field) |
| `[kubernetes]` | `disabled = false` (already in `format` line 2) |
| `[terraform]` | `disabled = false` |
| `[aws]` | `disabled = false` |
| `[gcloud]` | `disabled = false` |

---

## Customization Recipes

### Swap the color theme

Add another palette and point at it:

```toml
[palettes.solarized_dark]
muted    = "#586e75"
surface2 = "#073642"
blue     = "#268bd2"
# … define every name used by midnight_horizon …

palette = "solarized_dark"
```

### Show seconds in `$cmd_duration`

```toml
[cmd_duration]
show_milliseconds = true
```

### Always show username (not just root/SSH)

```toml
[username]
show_always = true
```

### Add a one-line variant for laptops with narrow terminals

Replace `format` with a single line by collapsing the box-drawing:

```toml
format = "$sudo$directory$git_branch$git_status$status$character "
```

### Add `$time` back, in 24-hour format

```toml
[time]
disabled    = false
time_format = "%H:%M"
```

…and add `$time` to the `format` string after `$cmd_duration`.

---

## Troubleshooting

### Glyphs render as boxes / question marks

You need a Nerd Font installed *and* selected in your terminal. This config
expects a Nerd Font v3 (e.g., `JetBrainsMono Nerd Font`,
`Hack Nerd Font Mono`). Ghostty: set `font-family` in `~/.config/ghostty/config`.

### Slow prompt

```sh
starship timings   # ranks every active module by render cost
```

`git_status` and `sudo` are usually the slowest. If `git_status` exceeds
`command_timeout`, you'll see warnings — bump `command_timeout` or, if you're
on a slow filesystem, simplify `[git_status]`.

### `$tag` doesn't show up

`tag_disabled` defaults to `true`. This config sets it to `false`. If you fork
`[git_commit]` into a new config, make sure to copy that line — otherwise the
`tag_symbol` and `$tag` in `format` are silently dead.

### Right prompt overlaps the input

`right_format` renders on the **last** line of a multi-line prompt. With this
config, that line is `$character` — runtimes appear next to it. If your
terminal is narrow enough that runtimes collide with where you type, you can
either:

1. Move runtimes to line 1: append them to the `format` string, drop
   `right_format`.
2. Shorten symbols (the version-only format keeps things compact already).

### Validate config without restarting your shell

```sh
STARSHIP_LOG=warn starship prompt --status=0 --keymap=insert --jobs=0
```

Any malformed module will print a warning. To inspect a single module's
output:

```sh
starship module git_status
```

### Reload after editing

Starship reads the config on **every prompt** — no shell restart needed. Just
press Enter.
