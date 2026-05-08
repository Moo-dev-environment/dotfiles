# LSP

LSP in this config is **driven entirely by LazyVim and its language extras**.
There is no hand-rolled `lua/plugins/lsp.lua` here — the relevant pieces
live in the extras enabled in `lazyvim.json`.

## Servers

| Server   | Source extra                  | Filetypes |
|----------|-------------------------------|-----------|
| `clangd` | `lang.clangd`                 | C, C++    |
| `pyright` + `ruff` | `lang.python`       | Python    |
| `jdtls`  | `lang.java`                   | Java      |
| `lua_ls` | LazyVim default               | Lua       |
| `bashls` | not enabled — add `lang.bash` if needed | sh, bash |

Mason auto-installs each server on first launch (mason-lspconfig +
mason-tool-installer, both wired by LazyVim).

## Formatters (conform.nvim, configured by LazyVim + extras)

| Filetype | Formatter            | Comes from |
|----------|----------------------|-----------|
| c, cpp   | `clang-format`       | `lang.clangd` |
| python   | `black` (+ `ruff`)   | `lang.python` |
| java     | `google-java-format` | `lang.java` |
| lua      | `stylua`             | LazyVim default |
| sh       | `shfmt`              | LazyVim default |

Format-on-save is on by default. Toggles:

- `:LazyFormatInfo` — show what would format the current buffer.
- `<leader>uf` — toggle global format-on-save.
- `<leader>uF` — toggle format-on-save for the current buffer.

Manual formatting: `<leader>cf` (LazyVim default).

## Keybindings

LazyVim's standard LSP bindings apply:

- `gd`, `gD`, `gr`, `gI`, `gy`, `K` — navigation / hover.
- `<leader>ca` — code action.
- `<leader>cr` — rename.
- `<leader>cf` — format.
- `<leader>cs` / `<leader>cS` — document / workspace symbols.
- `<leader>cd` — line diagnostics.

Reference: <https://www.lazyvim.org/keymaps#lsp>.

## Diagnostics UI

LazyVim configures `vim.diagnostic` with virtual text, signs, and
rounded float borders out of the box. `<leader>uD` toggles diagnostics.

## Adding another language

Append the matching extra to `"extras"` in `lazyvim.json` and restart, e.g.
`lazyvim.plugins.extras.lang.rust`,
`lazyvim.plugins.extras.lang.go`,
`lazyvim.plugins.extras.lang.bash`. Each extra defines its own LSP server,
formatter, debugger, and (when applicable) tree-sitter parser, so a single
line is usually all that's needed.

## Java specifics

`jdtls` requires a system **JDK 21+** on `$PATH`. See
[`troubleshooting.md`](troubleshooting.md#java-lsp-jdtls-quits-exit-1).

Per-project Java workspace lives at
`~/.local/state/nvim/jdtls/<project>/` (managed by `lang.java`). DAP for
Java works out of the box once jdtls has attached — same `<leader>d*`
keys as everything else.
