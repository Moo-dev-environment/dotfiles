# Developer Tools — macOS Setup

## Runtimes (managed by mise)

| Tool    | Version  | Command        |
|---------|----------|----------------|
| Node.js | 24.15.0  | `node`, `npm`  |
| Python  | 3.14.4   | `python3`      |
| Go      | 1.26.2   | `go`           |

Managed via `mise` — versions are set in `~/.config/mise/config.toml`.
Use `mise use <tool>@<version>` to switch or add runtimes.

---

## Package Managers & Build Tools

| Tool      | Purpose                          |
|-----------|----------------------------------|
| `brew`    | macOS package manager            |
| `npm`     | Node.js package manager          |
| `uv`      | Fast Python package/project manager |
| `git-lfs` | Git Large File Storage extension |

---

## Shell Enhancements

| Tool                          | Purpose                                      | Activation         |
|-------------------------------|----------------------------------------------|--------------------|
| `starship`                    | Cross-shell prompt                           | `07-prompt.zsh`    |
| `zoxide`                      | Frecency-based smart `cd`                    | `10-tools.zsh`     |
| `atuin`                       | Shell history TUI (Ctrl-R)                   | `10-tools.zsh`     |
| `fzf`                         | Fuzzy finder                                 | `05-fzf.zsh`       |
| `direnv`                      | Per-directory `.envrc` env loading           | `10-tools.zsh`     |
| `thefuck`                     | Auto-correct mistyped commands (`fuck`)      | `10-tools.zsh`     |
| `zsh-autosuggestions`         | Fish-style inline suggestions                | `06-plugins.zsh`   |
| `zsh-syntax-highlighting`     | Syntax coloring as you type                  | `06-plugins.zsh`   |
| `zsh-history-substring-search`| Up/down arrow history search                 | `06-plugins.zsh`   |

---

## TUI Tools

| Tool      | Purpose                        | Launch       |
|-----------|--------------------------------|--------------|
| `lazygit` | Full-featured Git TUI          | `lazygit`    |
| `btop`    | Resource/process monitor       | `btop`       |
| `htop`    | Interactive process viewer     | `htop`       |
| `k9s`     | Kubernetes cluster TUI         | `k9s`        |
| `tmux`    | Terminal multiplexer           | `tmux`       |
| `neovim`  | Modal text editor              | `nvim`       |
| `atuin`   | History search TUI             | `Ctrl-R`     |

---

## CLI Utilities

| Tool      | Purpose                                  | Replaces  |
|-----------|------------------------------------------|-----------|
| `bat`     | Syntax-highlighted file viewer           | `cat`     |
| `eza`     | Modern file lister with icons/git info   | `ls`      |
| `fd`      | Fast, user-friendly file search          | `find`    |
| `ripgrep` | Extremely fast code search (`rg`)        | `grep`    |
| `delta`   | Side-by-side git diff pager              | —         |
| `gh`      | GitHub CLI (PRs, issues, repos)          | —         |
| `jq`      | JSON processor and query tool            | —         |
| `yq`      | YAML/JSON/TOML processor                 | —         |
| `wget`    | Non-interactive network downloader       | —         |
| `curl`    | HTTP client and data transfer            | —         |
| `tldr`    | Simplified community man pages           | `man`     |
| `git`     | Version control                          | —         |
| `git-lfs` | Large file versioning                    | —         |

---

## GUI Applications

| App                 | Purpose                    | CLI command  |
|---------------------|----------------------------|--------------|
| Visual Studio Code  | Code editor                | `code`       |
| Warp                | Modern terminal emulator   | —            |

---

## Config Locations

| Item                   | Path                              |
|------------------------|-----------------------------------|
| zsh config modules     | `~/.config/conf.d/`               |
| mise global config     | `~/.config/mise/config.toml`      |
| starship config        | `~/.config/starship.toml`         |
| atuin config           | `~/.config/atuin/config.toml`     |
| neovim config          | `~/.config/nvim/`                 |
| tmux config            | `~/.config/tmux/tmux.conf`        |
| git config             | `~/.gitconfig`                    |

---

## Quick Reference

```sh
# Update all brew packages
brew upgrade

# Update all mise runtimes
mise upgrade

# Add a new runtime (e.g. ruby)
mise use --global ruby@latest

# Fuzzy-find a file and open in nvim
nvim $(fzf)

# Jump to a recent directory
cd <partial-name>        # powered by zoxide

# Search code
rg "pattern" ./src

# Kubernetes dashboard
k9s

# Git TUI
lazygit
```
