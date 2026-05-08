# Debugging

DAP comes from LazyVim's `dap.core` extra plus the per-language extras
(`lang.clangd` for codelldb, `lang.python` for debugpy, `lang.java` for
java-debug + java-test). All four are enabled in `lazyvim.json`.

## Stack

Pulled in by `lazyvim.plugins.extras.dap.core`:

- **mfussenegger/nvim-dap** — core DAP client.
- **rcarriga/nvim-dap-ui** + **nvim-neotest/nvim-nio** — windowed UI.
- **theHamsta/nvim-dap-virtual-text** — inline value annotations.
- **jay-babu/mason-nvim-dap.nvim** — Mason wrapper for DAP adapters.

Adapters are added by the language extras:

- **`lang.clangd`** — `codelldb` for C / C++ / Rust.
- **`lang.python`** — `debugpy` for Python.
- **`lang.java`** — `java-debug` + `java-test`, merged into the jdtls
  session by `nvim-jdtls`.

## Keymaps

LazyVim's standard `<leader>d*` group from `dap.core`:

| Keys           | Action                          |
|----------------|---------------------------------|
| `<leader>db`   | Toggle breakpoint               |
| `<leader>dB`   | Conditional breakpoint          |
| `<leader>dc`   | Continue                        |
| `<leader>dC`   | Run to cursor                   |
| `<leader>di`   | Step into                       |
| `<leader>do`   | Step over                       |
| `<leader>dO`   | Step out                        |
| `<leader>dt`   | Terminate                       |
| `<leader>dr`   | Toggle REPL                     |
| `<leader>dl`   | Run last                        |
| `<leader>du`   | Toggle DAP UI                   |
| `<leader>dw`   | Widgets (hover scope)           |

Reference: <https://www.lazyvim.org/extras/dap/core>.

## Typical C/C++ session

The fast path uses **`<leader>rD`** (defined in `lua/plugins/cpp.lua`):
it writes the buffer, recompiles the current file with
`-O0 -g3 -DLOCAL` plus the bundled `bits/stdc++.h` include path, then
launches **codelldb**. If `input.txt` / `in.txt` / `stdin.txt` lives next
to the source, it's piped on the debuggee's stdin automatically — no
manual `args` editing.

1. Set a breakpoint on the suspect line: `<leader>db`.
2. `<leader>rD` — recompiles `-g3` and launches codelldb.
3. `<leader>du` to bring up the DAP UI (scopes / stack / watches / REPL).
4. Step with `<leader>do` (over) / `<leader>di` (into) / `<leader>dO` (out);
   `<leader>dc` to continue.
5. `<leader>dt` to terminate.

If you'd rather drive it by hand, compile with `g++ -O0 -g -o app app.cpp`
yourself and use `<leader>dc` — the `lang.clangd` extra defines a
`Launch file` configuration that prompts for the binary path.

## Typical Python session

`<leader>dPt` runs the test under cursor (when test extras are loaded);
`<leader>dPr` debugs the current Python file. Plain `<leader>dc` will
prompt for the program when no launch.json exists.

## Java

Once jdtls has attached to a `.java` buffer, `<leader>dc` works the same
way. `nvim-jdtls` integrates with `dap.core` automatically — no extra
config needed.

## DAP UI layout

LazyVim's default layout: a sidebar with scopes / breakpoints / stacks /
watches, and a bottom panel with REPL / console. Override per-machine in
`lua/plugins/` if needed (`opts` of `rcarriga/nvim-dap-ui`).
