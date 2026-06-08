# Starship

**Starship** is the prompt — the text that appears before your cursor on every
shell line. It's a single fast binary that works identically in bash, zsh, fish,
etc. It renders *modules* (directory, git branch, language versions, exit
status…) but only the ones relevant to where you are, so the prompt stays clean
in an empty folder and grows informative inside a git repo or a project.

- **Live path:** `~/.config/starship.toml` → symlink → `starship/starship.toml`
- **Editing the file here edits the live prompt.** Changes apply on the **next**
  prompt — just press Enter. No reload command.
- This is a **deliberately minimal** prompt: directory + git only, single design
  goal being "fast and uncluttered."

## What you actually see

```
~/…/dotfiles main ?  ❯
└── dir ──┘ └br┘ └git┘ └ prompt char
```

- `~/…/dotfiles` — current directory, truncated to the last 2 components.
- `main` — git branch (italic cyan), shown only inside a repo.
- `?` / `` / etc. — git status symbols (untracked, modified, …).
- `❯` — the prompt character; turns into `✗` after a failed command.

---

## Line-by-line configuration

### Top level

```toml
add_newline = true
command_timeout = 200
format = "[$directory$git_branch$git_status]($style)$character"
```

- `add_newline = true` — print a blank line before each prompt, so commands
  aren't visually glued to the previous one's output.
- `command_timeout = 200` — give each helper command (e.g. the `git` calls
  Starship runs) **200 ms** max. If git is slow on a huge repo, the prompt
  degrades gracefully instead of hanging. (Default is 500 ms; this is tightened
  for snappiness.)
- `format` — the **left prompt layout**, in order: directory → git branch → git
  status → the prompt character. Everything in the `[...]($style)` wrapper shares
  the default style; `$character` is styled separately by its own module.
  Anything *not* listed here (hostname, username, language versions, time…) is
  simply not rendered.

### `[character]` — the prompt symbol

```toml
[character]
error_symbol   = "[✗](bold cyan)"
success_symbol = "[❯](bold cyan)"
```

The last symbol before your cursor. After a command that **succeeds** (exit 0)
it's `❯`; after one that **fails** (non-zero exit) it's `✗`. Both bold cyan here
(many themes colour the error red — this one keeps it monochrome-cyan on
purpose). The `[text](style)` syntax is Starship's inline markup: text in
brackets, style in parens.

### `[directory]` — the path segment

```toml
[directory]
truncation_length = 2
truncation_symbol = "…/"
repo_root_style  = "bold cyan"
repo_root_format = "[$repo_root]($repo_root_style)[$path]($style)[$read_only]($read_only_style) "
```

- `truncation_length = 2` — show at most the **last 2** path components. Deep
  paths collapse: `/home/moo/GITHUB/dotfiles/nvim/lua` → `nvim/lua`.
- `truncation_symbol = "…/"` — what marks the truncation, e.g. `…/nvim/lua`.
- `repo_root_style = "bold cyan"` — when you're inside a git repo, the repo's
  root folder name is highlighted bold cyan so you can see the project boundary.
- `repo_root_format` — overrides the layout *when inside a repo*: render the repo
  root (`$repo_root`) in the bold-cyan style, then the path within the repo
  (`$path`) in the normal style, then a read-only lock icon (`$read_only`) if the
  directory isn't writable, then a trailing space.

### `[git_branch]` — current branch

```toml
[git_branch]
format = "[$branch]($style) "
style  = "italic cyan"
```

Renders just the branch name (`$branch`) in italic cyan with a trailing space.
No branch symbol prefix — minimalism. Only appears inside a git repo.

### `[git_status]` — working-tree state

```toml
[git_status]
format     = '[$all_status]($style)'
style      = "cyan"
ahead      = "⇡${count} "
diverged   = "⇕⇡${ahead_count}⇣${behind_count} "
behind     = "⇣${count} "
conflicted = " "
up_to_date = " "
untracked  = "? "
modified   = " "
stashed    = ""
staged     = ""
renamed    = ""
deleted    = ""
```

This compresses the entire `git status` into a few glyphs after the branch.
`$all_status` expands to the concatenation of whichever of the below apply:

| Key | Shows when | Glyph |
|---|---|---|
| `ahead` | local is ahead of remote | `⇡N` (N commits ahead) |
| `behind` | local is behind remote | `⇣N` |
| `diverged` | both ahead **and** behind | `⇕⇡A⇣B` |
| `conflicted` | merge conflicts present | `` |
| `up_to_date` | clean & synced | `` |
| `untracked` | new, unstaged files | `?` |
| `modified` | tracked files changed | `` |
| `stashed` | something in the stash | `` |
| `staged` | changes staged for commit | `` |
| `renamed` | renamed files | `` |
| `deleted` | deleted files | `` |

> The icon glyphs are **Nerd Font** symbols — they only render correctly in a
> terminal using a Nerd Font (here: *CaskaydiaMono Nerd Font Mono*). In a plain
> font they'll show as tofu boxes.

`${count}`, `${ahead_count}`, `${behind_count}` are substituted with the actual
numbers from git.

---

## Why so minimal?

Notice what's **absent**: no username/hostname, no time, no language/runtime
versions, no exit-code number, no cloud/k8s/docker context. Those modules exist
in Starship but aren't in `format`, so they never render. The result is a prompt
that's two-or-three tokens wide and effectively free to draw. If you later want,
say, the Python version when in a Python project, add `$python` to `format` and a
`[python]` section — Starship only shows it inside a Python project anyway.

## Validate after editing

```bash
# Parse the config and print the effective settings (errors surface here):
STARSHIP_CONFIG=~/.config/starship.toml starship print-config | head

# Measure module render times if the prompt feels slow:
STARSHIP_CONFIG=~/.config/starship.toml starship timings
```

## Reference

- Full module/config docs: <https://starship.rs/config/>
- Preset gallery (copy-paste starting points): <https://starship.rs/presets/>
