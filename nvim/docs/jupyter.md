# Jupyter notebooks

Edit and run `.ipynb` notebooks inside Neovim, with plot output rendered
inline. Three plugins cooperate (all in
[`lua/plugins/jupyter.lua`](../lua/plugins/jupyter.lua)):

| Plugin | Role |
|--------|------|
| [GCBallesteros/jupytext.nvim](https://github.com/GCBallesteros/jupytext.nvim) | Opens `.ipynb` as editable `# %%` percent-format text; converts back to JSON on save. |
| [benlubas/molten-nvim](https://github.com/benlubas/molten-nvim) | Sends cells to a live Jupyter kernel and captures output. Python remote plugin. |
| [3rd/image.nvim](https://github.com/3rd/image.nvim) | Renders `image/png` output (matplotlib etc.) inline via the kitty graphics protocol. |

Inline images work because the terminal is **Ghostty** (kitty graphics) and
tmux has `allow-passthrough on`. On a terminal without kitty graphics you still
get everything except inline images.

## Environment (one shared kernel)

Two Python venvs, kept separate on purpose so data libraries can never break
Neovim's ability to talk to Python:

| venv | Contents | Purpose |
|------|----------|---------|
| `~/.venvs/nvim` | `pynvim`, `jupyter_client`, `jupytext` | Neovim's Python 3 host (`vim.g.python3_host_prog`, set in [`options.lua`](../lua/config/options.lua)). Molten runs here. |
| `~/.venvs/ds` | `ipykernel`, `numpy`, `pandas`, `matplotlib`, `scipy` | Registered as the Jupyter kernel **"Python (datascience)"**. Every notebook uses it. |

Add libraries to the kernel anytime: `~/.venvs/ds/bin/pip install <pkg>`
(no re-registration needed).

### Recreating the environment (new machine)

```sh
# Neovim's Python host
python3 -m venv ~/.venvs/nvim
~/.venvs/nvim/bin/pip install pynvim jupyter_client jupytext

# Kernel venv + register it
python3 -m venv ~/.venvs/ds
~/.venvs/ds/bin/pip install ipykernel numpy pandas matplotlib scipy
~/.venvs/ds/bin/python -m ipykernel install --user \
  --name datascience --display-name "Python (datascience)"
```

Then in nvim: `:Lazy sync` (installs the three plugins; Molten's build step
runs `:UpdateRemotePlugins` to register the remote plugin). Requires the
`magick` CLI on `PATH` (image.nvim's `magick_cli` processor) — `brew install
imagemagick`.

## Workflow

1. `nvim some_notebook.ipynb` — it opens as `# %%`-delimited Python.
2. `<leader>ji` — start the `datascience` kernel (`<leader>jI` to pick a
   different one).
3. Move into a cell, `<leader>jj` — run it and jump to the next cell
   (`<leader>jc` runs without moving). Text output appears inline as virtual
   text; plots open in an output window at the cell.
4. `<leader>je` — write the cell **outputs** back into the `.ipynb` (see below).
5. `:w` — jupytext converts the buffer back to notebook JSON.

### Getting plots to render

matplotlib only emits `image/png` (what image.nvim can draw) when the kernel
uses the **inline backend**. Put this near the top of the notebook:

```python
%matplotlib inline
```

Without it, `plt.show()` produces nothing and it looks like images are broken.

### Saving outputs into the `.ipynb`

jupytext saves **code only** — cell outputs are not part of the text
representation. To persist outputs (so the notebook shows results when opened
elsewhere), run `<leader>je` (`:MoltenExportOutput!`) before/after `:w`. On
reopening, `<leader>jn` (`:MoltenImportOutput`) pulls saved outputs back in.

## Keymaps (`<leader>j` — "jupyter")

| Keys | Action |
|------|--------|
| `<leader>ji` | Init kernel (`datascience`) |
| `<leader>jI` | Init kernel (choose from list) |
| `<leader>jc` | Run current cell |
| `<leader>jj` | Run current cell and advance to the next |
| `<leader>jl` | Run current line |
| `<leader>jv` | Run visual selection (visual mode) |
| `<leader>jr` | Re-run the cell the cursor is in |
| `<leader>jo` | Show output window |
| `<leader>jO` | Enter (focus) the output window |
| `<leader>jh` | Hide output |
| `<leader>jd` | Delete the cell's output |
| `<leader>je` | Export outputs → `.ipynb` |
| `<leader>jn` | Import outputs from `.ipynb` |
| `<leader>jx` | Interrupt the kernel |
| `<leader>jR` | Restart the kernel |
| `]j` / `[j` | Jump to next / previous `# %%` cell |

`<leader>jc`/`<leader>jj` are custom helpers in `jupyter.lua` that find the
`# %%` cell boundaries and hand the range to `:MoltenEvaluateVisual`.

## Troubleshooting

- **Notebook opens as a wall of JSON, or errors on open.** jupytext's
  conversion failed. Common causes:
  - `ValueError: ... does not have a 'language_info' metadata ... (currently
    auto:hydrogen)` — the notebook (e.g. a Colab export) lacks a resolvable
    language extension. This config avoids it by pinning `output_extension =
    "py"` in `jupyter.lua` (so the flag is `py:hydrogen`, not `auto:hydrogen`).
    If you see it, you're on an older config — set `output_extension = "py"`.
    Non-Python notebooks need the matching extension (`jl`, `r`, …) or a
    `custom_language_formatting` entry.
  - The `jupytext` CLI isn't found — check `jupytext --version` (it lives at
    `~/.local/bin/jupytext` via pipx; jupytext.nvim calls it off `$PATH`).
  - The notebook has **no `kernelspec`** at all — jupytext.nvim's
    `get_ipynb_metadata` errors indexing `kernelspec.language`. Add one:
    `jupytext --set-kernel datascience file.ipynb`.
  - A stale sidecar `.py` next to the notebook shadows reconversion — delete
    `<notebook>.py` and reopen.
- **`:MoltenInit` says no kernel / kernel not found.** Confirm the kernel is
  registered: `~/.venvs/nvim/bin/python -c "from jupyter_client.kernelspec
  import KernelSpecManager; print(KernelSpecManager().find_kernel_specs())"`
  should list `datascience`. Re-run the `ipykernel install` step if not.
- **Cells run but no image appears.** Check `%matplotlib inline` is in the
  notebook; run `:checkhealth image` (backend `kitty`, processor `magick_cli`);
  confirm `tmux show -gv allow-passthrough` is `on`.
- **`:checkhealth provider` shows no python3.** `vim.g.python3_host_prog` must
  point at `~/.venvs/nvim/bin/python` and that venv must have `pynvim`.
- **General health:** `:checkhealth molten`, `:checkhealth image`,
  `:checkhealth jupytext`.

A ready-made smoke-test notebook lives at `~/notebooks/test.ipynb`.
