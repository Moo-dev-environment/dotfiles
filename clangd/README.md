# clangd

**clangd** is the C/C++ **language server** — the background process that gives
your editor real-time error squiggles, autocomplete, go-to-definition, hover
docs, and formatting for C and C++. Neovim (via the LazyVim `lang.clangd` extra)
talks to it; this file tunes how clangd compiles your code when there's no
project build file.

- **Intended live path:** `~/.config/clangd/config.yaml`. ⚠️ **Currently NOT
  deployed** — `~/.config/clangd/` doesn't exist on this machine, so this repo
  file isn't applied yet. To activate it:
  ```bash
  mkdir -p ~/.config/clangd
  ln -sf ~/GITHUB/dotfiles/clangd/config.yaml ~/.config/clangd/config.yaml
  ```
  Until then, nvim's `lua/plugins/cpp.lua` is what passes clangd compile flags.
  After linking, clangd re-reads it on the next file opened (or `:LspRestart`).
- This is the **global, user-level** config. It applies to any C/C++ file that
  **doesn't** have its own `compile_commands.json` (a project build database). As
  soon as a real project provides that, the project's flags win and this file
  steps aside.

## Why this file exists

When you open a loose `.cpp` file — a competitive-programming solution, a quick
scratch file — there's no build system telling clangd which C++ standard to use
or which warnings to enable. Without guidance clangd guesses, often defaulting to
an old standard, so modern syntax lights up red even though it compiles fine. This
config sets sane defaults so single-file C++ "just works."

## The configuration

```yaml
CompileFlags:
  Add:
    - -std=gnu++20
    - -Wall
    - -Wextra
```

`CompileFlags.Add` is a list of flags clangd **appends** to the compile command
it uses internally for analysis. They affect diagnostics and completion only —
clangd doesn't produce a binary.

| Flag | Meaning |
|---|---|
| `-std=gnu++20` | Parse as **C++20** with GNU extensions enabled. `gnu++20` (vs `c++20`) keeps GCC-isms like `__int128`, statement-expressions, and `<bits/stdc++.h>` working — common in competitive programming. This is the key line: it stops C++20 features from being flagged as errors. |
| `-Wall` | Turn on the standard, broadly-useful warning set. Catches the usual footguns (unused variables, sign mismatches, missing returns…). |
| `-Wextra` | Turn on the *additional* warnings beyond `-Wall` — stricter still, surfacing more subtle issues. |

## Platform note (why no `-I` here)

```
# On Arch, GCC ships <bits/stdc++.h> in the default include path, so clangd
# resolves it natively — no extra -I needed.
```

`<bits/stdc++.h>` is a GCC convenience header that pulls in the entire standard
library at once (ubiquitous in competitive programming). On **Arch** (this
machine) the system GCC provides it in a path clangd already searches, so no
`-I` include-path flag is needed.

> **Contrast with macOS.** On macOS, Apple's libc++ does **not** ship
> `<bits/stdc++.h>`, so the nvim config carries a shim header under
> `nvim/include/` and adds `-I<nvim-config>/include` so clangd can find it. That
> macOS detail is documented in `../nvim/docs/cpp.md` /
> `../nvim/docs/troubleshooting.md`. On Arch you don't need it — hence this file
> stays minimal. **Do not** add a `Compiler: g++-…` line here: it breaks
> member-completion type resolution against the shim on the macOS side.

## How it relates to the editor

- The nvim **runner** (`<leader>r*`) and **CompetiTest** also pass their own
  `-std`/include flags when they actually *compile and run* code — so a program
  builds the same way it lints. This file governs the **editor diagnostics**; the
  runner governs **execution**. Keeping them in agreement (both C++20) means "no
  red squiggles" matches "it compiles."
- Formatting (`clang-format`) is configured separately, in nvim
  (`nvim/lua/plugins/cpp.lua`), not here.

## Validate after editing

clangd's config is YAML; the quickest check is functional:

```bash
# In nvim, open a .cpp file and run:  :LspRestart  then  :LspInfo
# or from a shell, confirm clangd parses the file without bogus errors:
clangd --check=/path/to/some.cpp 2>&1 | tail -20
```

## Reference

- clangd config format: <https://clangd.llvm.org/config>
- Compile flags come straight from clang/gcc: `man clang` / `man gcc`.
