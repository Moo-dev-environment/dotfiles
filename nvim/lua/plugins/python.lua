-- Keep Python completion, diagnostics, tests, and debugging on the shared ML
-- environment unless a project environment is selected explicitly.
local ds_python = vim.fn.expand("~/.venvs/ds/bin/python")

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = {
          settings = {
            python = {
              pythonPath = ds_python,
            },
          },
        },
      },
    },
  },
  {
    "nvim-neotest/neotest",
    optional = true,
    opts = {
      adapters = {
        ["neotest-python"] = {
          python = ds_python,
        },
      },
    },
  },
}
