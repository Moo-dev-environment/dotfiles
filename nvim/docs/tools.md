# Editor tools & power features

A how-to for the editing / navigation / git / AI plugins layered on top of
LazyVim. Each section says **what it does**, the **keys or commands**, and a
**"Try it"** walkthrough you can follow step by step. Leader is `<space>`.

If you only skim one thing, read the *Try it* boxes.

## Quick reference

| Tool | Trigger | One-liner |
|------|---------|-----------|
| mini.surround | `gsa` `gsd` `gsr` | add / delete / replace surrounding quotes & brackets |
| harpoon | `<leader>H` `<leader>h` `<leader>1`–`5` | pin a few files, jump between them instantly |
| dial.nvim | `<C-a>` `<C-x>` | increment/decrement numbers, dates, booleans |
| treesitter-context | automatic (`<leader>uK` toggles) | sticky function/scope header while scrolling |
| undotree | `<leader>U` | browse full undo history as a tree |
| nvim-colorizer | automatic | preview hex/rgb colors inline |
| rainbow-delimiters | automatic | color-match nested brackets |
| diffview | `<leader>gdo` `<leader>gdh` `<leader>gdc` | side-by-side git diff & file history |
| vim-tmux-navigator | `<C-h/j/k/l>` | move between nvim splits and tmux panes |
| auto-save | automatic (`:ASToggle`) | saves the file for you as you work |
| Copilot | `<S-Tab>` to accept | inline AI code suggestions |
| leetcode.nvim | `:Leet` | solve LeetCode problems inside nvim |

---

## Editing

### mini.surround — quotes, brackets, tags

Add, change, or remove the characters *around* text. The mappings here use a
`gs` prefix (LazyVim's convention so they don't clash with other keys).

| Keys | Action |
|------|--------|
| `gsa` + *motion* + *char* | **a**dd surround |
| `gsd` + *char* | **d**elete surround |
| `gsr` + *old* + *new* | **r**eplace surround |
| `gsf` / `gsF` | jump to next / previous surround |

`gsa` is an operator, so you give it a *motion* (like `iw` = inner word) then
the character to wrap with. In **visual mode**, select text first, then
`gsa` + char.

> **Try it.** Put the cursor on the word `hello` and type:
> 1. `gsaiw"` → `"hello"` *(surround inner word with quotes)*
> 2. `gsr"(` → `( hello )` *(replace `"` with parens — use `)` instead of `(` for no spaces: `(hello)`)*
> 3. `gsd(` → `hello` *(delete the surrounding parens)*

### dial.nvim — smart increment / decrement

`<C-a>` and `<C-x>` (Vim's increment/decrement) but they understand more than
numbers.

| Keys | Action |
|------|--------|
| `<C-a>` / `<C-x>` | increment / decrement the thing under the cursor |
| `g<C-a>` / `g<C-x>` (visual) | increment a selected column *sequentially* |

Works on: integers, hex (`0xff`), dates (`2026-06-08`), booleans
(`true`↔`false`), and the operators `&&`/`||`, `==`/`!=`, `and`/`or`.

> **Try it.** Cursor on `true`, press `<C-x>` → `false`. Cursor on a date like
> `2026-06-08`, press `<C-a>` → `2026-06-09`. Select a column of `0`s in visual
> block mode and press `g<C-a>` → they become `1, 2, 3, …`.

---

## Navigation

### harpoon — jump between your few "working" files

Instead of fuzzy-finding the same files over and over, *pin* them and jump with
one key. Perfect for the CP loop: source ↔ `input.txt` ↔ `expected_output.txt`.

| Keys | Action |
|------|--------|
| `<leader>H` | add the current file to the list |
| `<leader>h` | open the quick menu (reorder / delete / pick) |
| `<leader>1` … `<leader>5` | jump straight to pinned file 1…5 |

> **Try it.** Open `sol.cpp`, press `<leader>H`. Open `input.txt`, press
> `<leader>H`. Now from anywhere, `<leader>1` lands on `sol.cpp` and
> `<leader>2` on `input.txt`. `<leader>h` shows the list — inside it you can
> drag lines to reorder, `dd` to remove, `<CR>` to open.

### vim-tmux-navigator — one keymap for nvim + tmux

`<C-h>` `<C-j>` `<C-k>` `<C-l>` move between **nvim splits**, and seamlessly
cross into **tmux panes** when you hit the edge — no tmux prefix needed. This
pairs with the runner, which opens output in a tmux pane to the right.

> **Note:** the nvim side is wired up. For the jump to cross into *tmux panes*
> (not just nvim splits), your `~/.config/tmux/tmux.conf` needs the matching
> `christoomey/vim-tmux-navigator` setup. Ask and I can add that.

---

## Reading code

### treesitter-context — sticky scope header

When you scroll down inside a long function, the function signature (and any
enclosing `for`/`if`) stays pinned at the top of the window, so you always know
where you are. It's **automatic** — nothing to press.

- Toggle on/off: `<leader>uK`.

### rainbow-delimiters — colored brackets

Nested `()`, `[]`, `{}` get distinct colors so matching pairs are obvious at a
glance. Automatic.

### nvim-colorizer — inline color preview

Color literals like `#ff0000`, `rgb(0,128,255)`, or CSS/Tailwind colors are
shown with their actual color. Automatic; most useful in theme files and CSS.

---

## History

### undotree — visualize undo

Vim's undo isn't a straight line — if you undo and then type, it *branches*.
undotree shows the whole tree so you can recover any past state.

| Keys | Action |
|------|--------|
| `<leader>U` | toggle the undotree panel |

Inside the panel: move with `j`/`k` to walk states, `<CR>` to restore one,
`q` to close. Because LazyVim keeps **persistent undo** (`undofile`), the
history survives closing and reopening the file.

> **Try it.** Type some text, undo a bit (`u`), type something different, then
> `<leader>U`. You'll see two branches — pick either to jump back to it.

---

## Git

### diffview — full-window diffs & history

Complements LazyVim's inline git signs and `lazygit` (`<leader>gg`) with a
proper side-by-side view. **You must be inside a git repo.**

| Keys | Action |
|------|--------|
| `<leader>gdo` | open diff of uncommitted changes (left = old, right = new) |
| `<leader>gdh` | history of the **current file** (scroll through every commit) |
| `<leader>gdH` | history of the **whole repo** |
| `<leader>gdc` | close the view |

Inside: the left panel lists changed files (`<CR>` to open one); `]c` / `[c`
jump between changed hunks.

---

## AI

### Copilot — inline suggestions

As you type, Copilot shows a gray "ghost text" suggestion ahead of the cursor.

| Keys | Action |
|------|--------|
| `<S-Tab>` | accept the suggestion |
| `<M-]>` / `<M-[>` | next / previous suggestion |
| `<C-]>` | dismiss |

**One-time setup:** run `:Copilot auth` and follow the browser sign-in, then
`:Copilot status` to confirm. (Requires a GitHub Copilot subscription and
Node.js, which is installed.) Suggestions appear as ghost text rather than in
the completion popup because `vim.g.ai_cmp = false` in `options.lua`.

---

## Competitive programming

### leetcode.nvim — LeetCode in the editor

Browse, read, run, and submit LeetCode problems without leaving nvim. Default
solution language is **C++** (set in `lua/plugins/leetcode.lua`).

| Command | Action |
|---------|--------|
| `:Leet` | open the dashboard |
| `:Leet menu` | list / search problems |
| `:Leet test` | run the sample tests on your current solution |
| `:Leet submit` | submit the solution |
| `:Leet lang` | change the language for this problem |

**One-time setup:** run `:Leet` — on first use it prompts you to sign in (it
reads your leetcode.com session cookie from the browser). The `html`
treesitter parser is compiled the first time, too.

> **Try it.** `:Leet` → pick a problem → it opens a description pane and a code
> pane side by side. Write your solution in the code pane, `:Leet test` to check
> against the samples, then `:Leet submit`.

---

## See also

- [`keymaps.md`](keymaps.md) — terse list of every key this config adds.
- [`cpp.md`](cpp.md) / [`competitive-programming.md`](competitive-programming.md)
  — the `<leader>r*` runner and CompetiTest (`<leader>t*`) CP workflow.
- [`plugins.md`](plugins.md) — which file configures each plugin.
