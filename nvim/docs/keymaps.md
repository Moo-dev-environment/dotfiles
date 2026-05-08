# Keymaps

This page documents only the keymaps this config **adds on top of LazyVim**.
For every other binding (`<C-h/j/k/l>`, `<S-l>/<S-h>`, `<leader>f*`,
`<leader>g*`, `<leader>l*`, `<leader>x*`, `<leader>e`, etc.) see the LazyVim
reference: <https://www.lazyvim.org/keymaps>.

Leader is `<space>`.

## Run (custom — `lua/cp/runner.lua`, mounted in `lua/config/keymaps.lua`)

The runner detects whether you're inside tmux. In tmux it pops the run in a
new pane to the right (`tmux split-window -h -l 45%`). Outside tmux it falls
back to a `:terminal` split below.

| Keys           | Action                                                 |
|----------------|--------------------------------------------------------|
| `<leader>rr`   | Compile and run (stdin from `input.txt` if present)    |
| `<leader>rc`   | Compile only                                           |
| `<leader>ri`   | Edit `input.txt`                                       |
| `<leader>ro`   | Edit `expected_output.txt`                             |
| `<leader>rd`   | Diff actual stdout vs `expected_output.txt`            |
| `<leader>rD`   | Compile C/C++ with `-O0 -g3` and launch debugger (codelldb via DAP); pipes `input.txt` / `in.txt` / `stdin.txt` to stdin if present. See `lua/plugins/cpp.lua` and docs/debugging.md. |

The pane / terminal pauses on "press any key to close…" so the output stays
visible after the program exits.

## Competitive-programming tests (competitest.nvim — `lua/plugins/competitest.lua`)

| Keys           | Action                                              |
|----------------|-----------------------------------------------------|
| `<leader>ta`   | Add test case                                       |
| `<leader>te`   | Edit test cases                                     |
| `<leader>tR`   | Run all test cases                                  |
| `<leader>tu`   | Run without recompiling                             |
| `<leader>tr`   | Receive test cases (Competitive Companion browser)  |
| `<leader>tp`   | Receive full problem (creates source from template) |
| `<leader>tc`   | Receive entire contest                              |

## What you get from LazyVim extras (no extra config)

The five enabled extras (`dap.core`, `editor.neo-tree`, `lang.clangd`,
`lang.python`, `lang.java`) provide their own keymaps via LazyVim's
standard groups:

- **DAP** — `<leader>d*` group (toggle breakpoint, continue, step in/over/out,
  REPL, etc.). Reference: <https://www.lazyvim.org/extras/dap/core#keymaps>.
- **LSP** — `gd`, `gr`, `gI`, `gy`, `K`, `<leader>ca`, `<leader>cr`,
  `<leader>cs`, formatting. Reference:
  <https://www.lazyvim.org/keymaps#lsp>.
- **Test runner** (Java/Python via DAP-test integrations) — `<leader>t*` is
  used in some lang extras for tests; that conflicts with our competitest
  binding. Competitest wins because the spec file's `keys =` is loaded
  later. If you want both, rename the competitest leader to e.g.
  `<leader>cp*`.
