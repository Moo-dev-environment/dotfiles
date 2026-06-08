# Competitive programming

Two complementary tools:

- **competitest.nvim** (`lua/plugins/competitest.lua`) — graded workflow:
  multiple test cases, parallel runs, pass/fail UI, Competitive Companion
  integration.
- **Custom runner** (`lua/cp/runner.lua` + `<leader>r*` keymaps in
  `lua/config/keymaps.lua`) — debugging loop: hit one key, see stdout in a
  tmux pane.

## `<bits/stdc++.h>`

On Arch this ships with GCC at
`/usr/include/c++/<ver>/x86_64-pc-linux-gnu/bits/stdc++.h`, so it's on the
default include path for both `g++` and clangd — nothing extra to configure.
Your CP sources `#include <bits/stdc++.h>` directly; the runner and
competitest compile with `g++`, and editor diagnostics come from clangd,
all of which find it natively.

## competitest.nvim

| Keys          | Command                             | What it does |
|---------------|-------------------------------------|---------------|
| `<leader>ta`  | `:CompetiTestAdd`                   | Add a test case. |
| `<leader>te`  | `:CompetiTestEdit`                  | Edit existing test cases. |
| `<leader>tR`  | `:CompetiTestRun`                   | Compile + run every test case. |
| `<leader>tu`  | `:CompetiTestRunNoCompile`          | Run without recompiling. |
| `<leader>tr`  | `:CompetiTestReceive testcases`     | Receive test cases from the browser. |
| `<leader>tp`  | `:CompetiTestReceive problem`       | Receive a whole problem (creates source file + tests). |
| `<leader>tc`  | `:CompetiTestReceive contest`       | Receive an entire contest as a batch. |

### Test case layout

Tests live next to the source (not in a subdir):

- Input:  `<stem>_input<N>.txt`
- Output: `<stem>_output<N>.txt`

### Received-problem paths

- Single problem: `$(CWD)/$(PROBLEM).$(FEXT)` — lands directly in the
  current working directory. `received_problems_prompt_path = false`,
  so there's no path confirmation; useful for one-off problems where
  you've already `cd`'d into the right folder.
- Contest: `$HOME/cp/$(JUDGE)/$(CONTEST)/<problem>.$(FEXT)`. You **are**
  prompted for the directory and extension on first use of each judge
  (`received_contests_prompt_directory` / `received_contests_prompt_extension`).

### Compile/run defaults (from `lua/plugins/competitest.lua`)

- **C++**: `g++ -O2 -std=gnu++20 -Wall -Wextra -Wshadow -DLOCAL -o $(FNOEXT) $(FNAME)`
- **C**:   `gcc -O2 -std=gnu17 -Wall -Wextra -o $(FNOEXT) $(FNAME) -lm`
- **Java**: `javac` then `java $(FNOEXT)`
- **Python**: no compile, `python3 $(FNAME)` to run
- **Rust**: `rustc -O` then `./$(FNOEXT)`

Runner UI is a popup at 85% × 80% of the screen. `multiple_testing = -1`
uses all cores. 5-second time limit. Output comparison is `squish`
(whitespace-insensitive). `view_output_diff = true` opens a diff on mismatch.

### Competitive Companion setup

1. Install [Competitive Companion](https://github.com/jmerle/competitive-companion).
2. In its options, set the custom port to **27121**.
3. Open Neovim, run `<leader>tp` (or `<leader>tr` / `<leader>tc`).
4. Click the Competitive Companion icon on the problem page. The file +
   tests land in `~/cp/...` and the buffer opens.

## Custom runner (`lua/cp/runner.lua`)

Single-input-file workflow. No test scaffolding, no popup UI — just compile
and run with stdout in a real tmux pane (or a `:terminal` split if you're
not in tmux).

### Behavior

- `M.run()` (`<leader>rr`): writes the buffer, compiles, runs. If
  `input.txt` / `in.txt` / `stdin.txt` exists in the buffer's directory,
  it's piped on stdin. Python skips compile.
- `M.compile()` (`<leader>rc`): writes + compiles only.
- `M.edit_input()` (`<leader>ri`): opens `input.txt` next to the source.
- `M.edit_output()` (`<leader>ro`): opens `expected_output.txt`.
- `M.diff_output()` (`<leader>rd`): compiles, runs with `input.txt` on
  stdin, diffs stdout against `expected_output.txt` via `diff -u`.

### tmux integration

Inside tmux (`$TMUX` set), the runner shells out to:

```
tmux split-window -h -l 45% '<cmd>; ec=$?; printf "[exit %s] press any key…" "$ec"; read -n1 -r'
```

You get a real tmux pane: resize with `<prefix> M-h/l`, scroll/copy via
tmux copy-mode, and Alacritty's OSC52 forwards the system clipboard out.
Outside tmux it falls back to `:botright 15split | terminal`.

### Language detection

| Extension           | Compile                                                                 | Run             |
|---------------------|-------------------------------------------------------------------------|------------------|
| `.c`                | `gcc -O2 -std=gnu17 -Wall -Wextra -o <stem> <name> -lm`                 | `./<stem>`       |
| `.cpp/.cc/.cxx`     | `g++ -O2 -std=gnu++20 -Wall -Wextra -Wshadow -DLOCAL -o <stem> <name>` | `./<stem>` |
| `.java`             | `javac <name>`                                                          | `java <stem>`    |
| `.py`               | (none)                                                                  | `python3 <path>` |

### When to use which

- **competitest** for graded test cases, contest receive, parallel runs,
  diffs against many expected outputs.
- **Custom runner** for the inner debug loop while you're iterating —
  faster to invoke, output stays in a tmux pane you can scroll, pairs with
  a `dbg(...)` macro in your `-DLOCAL` boilerplate.
