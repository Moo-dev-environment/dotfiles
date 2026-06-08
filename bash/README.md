# Bash

**Bash** is the default login shell on Omarchy/Arch. These are the small
startup files that bash reads when a shell starts. They're intentionally thin —
almost all the real shell behaviour (aliases, functions, prompt, completions)
comes from **Omarchy's defaults**, which these files `source` rather than
duplicate.

> **Note — these files are COPIES, not symlinks.** Unlike the other tools in this
> repo, `~/.bashrc` etc. are *not* symlinked to this directory. The files here are
> a snapshot for reference/backup. Editing a file here does **not** change your
> live shell — edit `~/.bashrc` directly for that, then re-copy here if you want
> the repo to stay current. (This was a deliberate choice; bash is a fallback
> shell on this machine, with the primary interactive config being zsh — see
> `../zsh/`.)

## Which file runs when?

Bash has a slightly confusing startup model. The short version:

| File | Read when |
|---|---|
| `.bash_profile` | a **login** shell starts (TTY login, SSH, or the first shell of a graphical session) |
| `.profile` | login shells of `sh`-compatible shells; bash uses it only if `.bash_profile` is absent (kept here for portability) |
| `.bashrc` | every **interactive non-login** shell (each new terminal/tmux pane) |
| `.bash_logout` | a login shell **exits** |

The standard idiom (used here) is for `.bash_profile` to source `.bashrc`, so a
login shell gets the interactive setup too — meaning in practice `.bashrc` is
where everything lives.

---

## `.bashrc`

```bash
# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return
```

`$-` is the set of current shell flags; it contains `i` only for **interactive**
shells. So this line says: if this shell isn't interactive (e.g. it's running a
script), do nothing further and return immediately. This guard must stay at the
top — sourcing interactive-only setup in a script context can break things or
slow them down.

```bash
# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
source ~/.local/share/omarchy/default/bash/rc
```

Pulls in **Omarchy's** entire default bash setup — its aliases, helper functions,
prompt, completion wiring, etc. This is why your bash feels configured even
though these files are nearly empty: the substance lives in Omarchy's managed
file, which gets updated when Omarchy updates. The comment is the key guidance:
**don't edit Omarchy's file; override below it.** Anything you define *after* this
line wins over the defaults.

```bash
. "$HOME/.local/share/../bin/env"
```

Sources an `env` script (the odd `.local/share/../bin` path normalises to
`~/.local/bin/env`). This is typically written by a toolchain installer (e.g.
**Rust/Cargo** or **mise/uv**) to put its binaries on `$PATH`. `.` is the POSIX
synonym for `source`.

> Your personal aliases/exports/functions go **between** the Omarchy `source`
> line and (or after) the `env` line — that's the "Add your own … here" spot in
> the live file.

---

## `.bash_profile`

```bash
[[ -f ~/.bashrc ]] && . ~/.bashrc
. "$HOME/.local/share/../bin/env"
```

For login shells: if `.bashrc` exists, source it (so login shells get the full
interactive config), then ensure the `env` PATH additions are present. Without
the first line, a login shell — like an SSH session — would skip `.bashrc`
entirely and you'd lose all your aliases.

---

## `.profile`

```bash
. "$HOME/.local/share/../bin/env"
```

A minimal POSIX-shell profile that just loads the `env` PATH script. It exists so
that `sh`-only contexts (some display managers, cron, scripts invoked as `sh -l`)
still get the toolchain on `$PATH`, even though they won't read bash-specific
files.

---

## `.bash_logout`

```bash
#
# ~/.bash_logout
#
```

Runs when a login shell exits. Currently just the stock header comment — a place
to put cleanup (e.g. `clear` to wipe the screen on logout) if you ever want it.

---

## Best practices

- **Add personal config to `~/.bashrc`** (the live file), after the Omarchy
  `source` line. Keep it idempotent and fast — it runs for every new shell.
- **Don't edit Omarchy's `default/bash/rc`** — it's overwritten on update.
  Override instead.
- After editing the live `~/.bashrc`, apply it with `source ~/.bashrc` (or just
  open a new terminal). If you want this repo copy to match, re-copy the files.

## Validate after editing

```bash
# Syntax-check without running it:
bash -n ~/.bashrc && echo "syntax OK"

# Full interactive load test (should return cleanly):
bash -ic ':' && echo "loads OK"
```
