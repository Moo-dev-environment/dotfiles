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
| `<leader>tp`   | Receive full problem (creates source + tests)       |
| `<leader>tc`   | Receive entire contest                              |

## Jupyter notebooks (`lua/plugins/jupyter.lua`)

Under the `<leader>j` group. Full workflow in [`jupyter.md`](jupyter.md).

| Keys | Action |
|------|--------|
| `<leader>ji` / `<leader>jI` | Init `datascience` kernel / choose kernel |
| `<leader>jc` / `<leader>jj` | Run cell / run cell and advance |
| `<leader>jl` / `<leader>jv` | Run line / run visual selection |
| `<leader>jr` | Re-run current cell |
| `<leader>jo` / `<leader>jO` / `<leader>jh` | Show / enter / hide output |
| `<leader>je` / `<leader>jn` | Export outputs → `.ipynb` / import from `.ipynb` |
| `<leader>jx` / `<leader>jR` | Interrupt / restart kernel |
| `]j` / `[j` | Next / previous `# %%` cell |

## Editor & navigation tools

Full how-to with examples in [`tools.md`](tools.md); this is just the key list.

| Keys | Action | Tool |
|------|--------|------|
| `gsa` / `gsd` / `gsr` | add / delete / replace surrounding quotes·brackets | mini.surround |
| `<C-a>` / `<C-x>` | increment / decrement (numbers, dates, `true`/`false`) | dial.nvim |
| `g<C-a>` / `g<C-x>` | sequential inc/dec over a visual selection | dial.nvim |
| `<leader>H` | pin current file | harpoon |
| `<leader>h` | open harpoon quick menu | harpoon |
| `<leader>1` … `<leader>5` | jump to pinned file 1…5 | harpoon |
| `<leader>U` | toggle undo-history tree | undotree |
| `<leader>uK` | toggle sticky scope header | treesitter-context |
| `<leader>gdo` / `<leader>gdc` | open / close git diff view | diffview |
| `<leader>gdh` / `<leader>gdH` | file / repo git history | diffview |
| `<C-h/j/k/l>` | move across nvim splits **and** tmux panes | vim-tmux-navigator |
| `<S-Tab>` | accept Copilot ghost-text suggestion | Copilot |
| `<M-]>` / `<M-[>` / `<C-]>` | next / prev / dismiss Copilot suggestion | Copilot |

Commands (no default keymap): `:Leet` (LeetCode), `:Copilot auth` (sign in),
`:ASToggle` (turn auto-save off/on). treesitter-context, rainbow-delimiters,
nvim-colorizer and auto-save run automatically with no key to press.

## What you get from LazyVim extras (no extra config)

The enabled extras (`coding.mini-surround`, `dap.core`, `editor.harpoon2`,
`editor.neo-tree`, `lang.clangd`, `lang.python`, `lang.java`, plus the
`ai.copilot` import) provide their own keymaps via LazyVim's standard groups:

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
