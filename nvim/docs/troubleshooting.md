# Troubleshooting

LazyVim handles most of the historical pain points (treesitter branch
pinning, mason path changes, lspconfig deprecation) — they're absorbed into
the distribution and not worth re-documenting here. What follows is the
shortlist of issues that are still likely to bite.

## Java LSP (`jdtls`) quits exit 1

**Symptom:** `Client jdtls quit with exit code 1` in `:LspLog` or
`:messages` as soon as you open a `.java` file.

**Cause:** no JDK runtime available on `$PATH`. jdtls is itself a Java
program and needs a **JRE ≥ 21** to launch.

**Fix on Linux (Arch / Omarchy):**

```sh
sudo pacman -S jdk21-openjdk
sudo archlinux-java set java-21-openjdk
java -version    # should print 21+
```

**Fix on macOS:**

```sh
brew install openjdk@21
sudo ln -sfn /opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk \
             /Library/Java/JavaVirtualMachines/openjdk-21.jdk
/usr/libexec/java_home -V    # confirm visibility
```

Restart Neovim, reopen the `.java` file.

## `fatal error: 'bits/stdc++.h' file not found` (clangd / Apple clang) {#fatal-error-bitsstdch-file-not-found-clangd--apple-clang}

**Symptom:** clangd red-squiggles `#include <bits/stdc++.h>` on macOS.

**Cause:** Apple clang's libc++ does not ship that GCC convenience header.

**Fix:** the shim is bundled at `~/.config/nvim/include/bits/stdc++.h`. The
runner and competitest already pass `-I<stdpath("config")>/include`. Tell
clangd by creating `~/.config/clangd/config.yaml`:

```yaml
CompileFlags:
  Add:
    - -I/Users/<you>/.config/nvim/include
    - -std=gnu++20
    - -Wall
    - -Wextra
```

On Linux (GCC) you don't need this — the header already exists in the
system include path.

## Extras are not loading after editing `lazyvim.json`

**Symptom:** added a line to `"extras"` in `lazyvim.json`, but `:Lazy`
still doesn't show the new plugins.

**Fix:** restart Neovim, then `:Lazy sync`. LazyVim reads `lazyvim.json` at
startup — editing it doesn't hot-reload. Mason will install the missing
servers / formatters / debuggers on next launch.

## Runner pane doesn't open

**Symptom:** `<leader>rr` does nothing or errors.

**Checks:**

1. Buffer must be saved at least once (the runner refuses an empty path).
2. Filetype must be `c`, `cpp`, `cc`, `cxx`, `java`, or `py`.
3. Inside tmux: `echo $TMUX` must be non-empty in the shell that started
   nvim. If you `nvim` from outside tmux and then attach to tmux, `$TMUX`
   isn't propagated — restart nvim from inside the tmux pane.
4. Outside tmux: the fallback uses `:botright 15split | terminal`. If
   `:terminal` errors, your nvim build is missing `+terminal`.

## Competitive Companion doesn't deliver problems

**Symptom:** `<leader>tp` or `<leader>tr` waits forever; clicking the
browser icon does nothing.

**Checks:**

1. The browser extension's port matches the value in
   `lua/plugins/competitest.lua` — both must be `27121`.
2. No firewall blocking localhost on that port.
3. The buffer is in receive mode: you must invoke
   `:CompetiTestReceive ...` *before* clicking the browser icon. The
   listener is short-lived.

## `<leader>t*` keys clash with LazyVim test extras

**Symptom:** binding a language extra with built-in test runners (e.g.
some `lang.*` variants use `<leader>t*` for tests) causes which-key
fights.

**Fix:** the user spec wins because lazy.nvim merges keys late, but if you
care about tidiness, rename the competitest leader (e.g. to `<leader>cp*`)
in `lua/plugins/competitest.lua`.
