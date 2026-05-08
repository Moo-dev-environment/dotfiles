# C / C++ workflow

How to run, test, debug, and format C/C++ in this config.

The CP-specific scaffolding (CompetiTest, custom runner, templates, the
`bits/stdc++.h` shim) is documented in
[`competitive-programming.md`](competitive-programming.md). This page is
the **task-oriented "how do I do X"** view.

## What's wired up

| Concern | Tool | Source |
|---|---|---|
| LSP (completion, diagnostics, go-to-def) | `clangd` | `lazyvim.plugins.extras.lang.clangd` |
| Formatter | `clang-format` via `conform.nvim` | `lua/plugins/cpp.lua` |
| Debugger | `codelldb` via `nvim-dap` | `lazyvim.plugins.extras.dap.core` + `lang.clangd` |
| Single-file run | custom `cp.runner` | `lua/cp/runner.lua` |
| Multi-testcase grading | CompetiTest | `lua/plugins/competitest.lua` |
| Compile flags (run/test) | `-O2 -std=gnu++20 -Wall -Wextra -Wshadow -DLOCAL -I~/.config/nvim/include` | runner + competitest |
| Compile flags (debug) | `-O0 -g3 -std=gnu++20 -Wall -Wextra -DLOCAL -I~/.config/nvim/include` | `<leader>rD` in `cpp.lua` |
| Mason-pinned tools | `clangd`, `clang-format`, `codelldb` | `lua/plugins/cpp.lua` |

## Three ways to run code

### 1. Quick compile & run — `<leader>r*` (custom runner)

For a single file with optional `input.txt`. Output lands in a tmux pane to
the right (or `:terminal` split if you're not in tmux).

| Keys | Action |
|---|---|
| `<leader>rr` | Compile + run (pipes `input.txt` / `in.txt` / `stdin.txt` if present) |
| `<leader>rc` | Compile only |
| `<leader>ri` | Edit `input.txt` next to the source |
| `<leader>ro` | Edit `expected_output.txt` |
| `<leader>rd` | Compile, run, `diff -u` against `expected_output.txt` |
| `<leader>rD` | Compile `-O0 -g3` and launch codelldb (see [Debugging](#debugging)) |

Implementation: [`lua/cp/runner.lua`](../lua/cp/runner.lua) — detects
language from extension (`.c` / `.cpp` / `.cc` / `.cxx`), picks the right
toolchain, and shells out via `tmux split-window -h -l 45%` when `$TMUX`
is set.

**Typical flow:**

1. `:e sol.cpp` → opens a buffer (CP template auto-fills via the
   `BufNewFile` autocmd in `lua/config/autocmds.lua`).
2. Write `solve()`.
3. `<leader>ri` → paste sample input → `:wq`.
4. `<leader>rr` → tmux pane shows stdout, exit code, and `time` numbers.
5. Optional: `<leader>ro` to save the expected answer → `<leader>rd` for
   a unified diff on every subsequent run.

### 2. Multi-testcase grading — `<leader>t*` (CompetiTest)

For when you have several samples or pull problems from the
[Competitive Companion](https://github.com/jmerle/competitive-companion)
browser extension (port `27121`).

| Keys | Action |
|---|---|
| `<leader>tr` | Receive testcases for the current file from the browser |
| `<leader>tp` | Receive a problem (creates source from template + tests under `~/cp/$JUDGE/$CONTEST/`) |
| `<leader>tc` | Receive an entire contest |
| `<leader>ta` | Add a testcase manually |
| `<leader>te` | Edit existing testcases |
| `<leader>tR` | Run **all** testcases in parallel |
| `<leader>tu` | Run all testcases without recompiling |

Test files sit next to the source as `<stem>_input<N>.txt` /
`<stem>_output<N>.txt`. The runner UI is a popup at 85%×80%; `multiple_testing = -1`
fans out across all CPU cores; comparison is `squish` (whitespace-insensitive);
mismatches open a side-by-side diff.

Full reference: [`competitive-programming.md`](competitive-programming.md).

### 3. Step-through debugging — `<leader>rD` + `<leader>d*`

`<leader>rD` is the C/C++ entry point: it writes the buffer, recompiles
the current file with `-O0 -g3 -DLOCAL`, and launches **codelldb**. If an
`input.txt` / `in.txt` / `stdin.txt` lives next to the source, it's piped
on the debuggee's stdin automatically — no manual `args` editing.

Once the session is up, the LazyVim `<leader>d*` group drives it:

| Keys | Action |
|---|---|
| `<leader>db` | Toggle breakpoint |
| `<leader>dB` | Conditional breakpoint |
| `<leader>dc` | Continue |
| `<leader>dC` | Run to cursor (LazyVim default — **don't shadow this**) |
| `<leader>di` / `<leader>do` / `<leader>dO` | Step into / over / out |
| `<leader>du` | Toggle DAP UI (scopes / stack / watches / REPL) |
| `<leader>dw` | Hover scope widget |
| `<leader>dt` | Terminate |
| `<leader>dl` | Run last config |

**Typical flow:**

1. Set a breakpoint on the suspect line: `<leader>db`.
2. `<leader>rD` — recompiles `-g3` and stops at the first breakpoint.
3. `<leader>du` to bring up scopes; step with `<leader>do` / `<leader>di`.
4. `<leader>dt` to stop.

If you'd rather use LazyVim's "Launch file" picker instead of `<leader>rD`,
`<leader>dc` works too — but you have to compile with `-g` yourself and
type the binary path on each launch.

See [`debugging.md`](debugging.md) for the DAP stack (nvim-dap, dap-ui,
dap-virtual-text, mason-nvim-dap).

## Formatting (`clang-format`)

`conform.nvim` is wired to run `clang-format` on `c` and `cpp` buffers.
Trigger via:

- `<leader>cf` (LazyVim's format keymap) — formats the buffer.
- Save — formats automatically (LazyVim's `format_on_save` defaults).

### Style

`clang-format` reads the nearest `.clang-format` walking up from the file.
This config ships:

- **Inline default** in `lua/plugins/cpp.lua` (`prepend_args` on the
  `clang-format` formatter): LLVM base, 4-space indent, `ColumnLimit: 0`
  (no reflow), short ifs/loops/functions kept on one line,
  `SortIncludes: false` so `#include <bits/stdc++.h>` stays put.
- **`~/cp/.clang-format`** — same style, picked up by CLI `clang-format`
  and any tool walking the tree (so CompetiTest-received problems under
  `~/cp/$JUDGE/$CONTEST/` are formatted identically).

To override per-project, drop a `.clang-format` next to (or above) the
source — it wins over the inline conform args.

## Indentation, tabs, comments

`ftplugin/cpp.lua` and `ftplugin/c.lua` set per-buffer:

- `shiftwidth = 4` · `tabstop = 4` · `softtabstop = 4` · `expandtab = true`
- `commentstring = "// %s"` (so `gcc`/`gc` comments use C++-style)

These match the `.clang-format` style, so format-on-save won't fight your
manual edits.

## `<bits/stdc++.h>`

Bundled at `~/.config/nvim/include/bits/stdc++.h`. Both the runner and
CompetiTest pass `-I~/.config/nvim/include`, so it's always in scope. On
Linux with GCC the header already exists in
`/usr/include/c++/<ver>/x86_64-pc-linux-gnu/bits/stdc++.h` — the bundled
shim is a fallback for non-GCC toolchains. macOS clangd needs an extra
config file; see
[`troubleshooting.md`](troubleshooting.md#fatal-error-bitsstdch-file-not-found-clangd--apple-clang).

## Templates

`BufNewFile *.cpp,*.cc,*.cxx` reads `~/.config/nvim/templates/cp.cpp` into
the new buffer (`lua/config/autocmds.lua`). The template includes
`bits/stdc++.h`, common typedefs (`ll`, `pii`, `vi`, …), `all(x)` /
`sz(x)` macros, a `dbg(x)` macro that's a no-op without `-DLOCAL`, and a
`solve()` skeleton with an optional multi-testcase loop.

Same idea for `.c`, `.py`, `.java` — see the templates dir.

## Tooling installs (Mason)

`lua/plugins/cpp.lua` adds these to Mason's `ensure_installed` so a fresh
machine self-provisions on first launch:

- `clangd`
- `clang-format`
- `codelldb`

Run `:Mason` to inspect status. `:checkhealth lazyvim` reports green when
all three are present.

## End-to-end smoke test

```bash
mkdir -p ~/cp/demo && cd ~/cp/demo
nvim a.cpp
```

In nvim:

1. Template auto-fills. Replace `solve()` with:
   ```cpp
   void solve() {
       int n; cin >> n;
       cout << n * n << '\n';
   }
   ```
2. `<leader>ri` → type `5` → `:wq`.
3. `<leader>rr` → tmux pane prints `25` and `time` output.
4. `<leader>ta` → add another case (input `7`, expected `49`).
5. `<leader>tR` → both cases green.
6. Set a breakpoint inside `solve()` with `<leader>db`, then `<leader>rD`
   — codelldb pauses at the breakpoint with `5` already on stdin.

That's the whole loop.

## Related docs

- [`competitive-programming.md`](competitive-programming.md) — CompetiTest
  config, Competitive Companion setup, received-problem paths, `cp.runner`
  internals.
- [`debugging.md`](debugging.md) — DAP architecture, all `<leader>d*`
  keymaps, Python/Java sessions.
- [`keymaps.md`](keymaps.md) — every keymap this config adds on top of
  LazyVim.
- [`troubleshooting.md`](troubleshooting.md) — common gotchas.
