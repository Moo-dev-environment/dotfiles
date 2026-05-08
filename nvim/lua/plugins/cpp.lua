-- C/C++ tooling: pin Mason tools, conform style for CP, DAP launch with input.txt.
return {
  -- Make sure the toolchain auto-installs.
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "clangd", "clang-format", "codelldb" })
    end,
  },

  -- clang-format with CP-friendly style. Also reads any `.clang-format`
  -- found up the tree, so per-project overrides still win.
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        c = { "clang-format" },
        cpp = { "clang-format" },
      },
      formatters = {
        ["clang-format"] = {
          prepend_args = {
            "--style={ BasedOnStyle: LLVM, IndentWidth: 4, TabWidth: 4, "
              .. "UseTab: Never, ColumnLimit: 0, AccessModifierOffset: -4, "
              .. "AllowShortFunctionsOnASingleLine: All, "
              .. "AllowShortIfStatementsOnASingleLine: WithoutElse, "
              .. "AllowShortLoopsOnASingleLine: true, "
              .. "SortIncludes: false, IndentCaseLabels: true }",
          },
        },
      },
    },
  },

  -- CP debug: <leader>rD compiles current file with -g and launches codelldb,
  -- piping `input.txt` (or in.txt / stdin.txt) on stdin if present.
  {
    "mfussenegger/nvim-dap",
    keys = {
      {
        "<leader>rD",
        function()
          local ft = vim.bo.filetype
          if ft ~= "cpp" and ft ~= "c" then
            return vim.notify("CP debug is C/C++ only", vim.log.levels.WARN)
          end
          vim.cmd("write")

          local path = vim.api.nvim_buf_get_name(0)
          local dir = vim.fn.fnamemodify(path, ":p:h")
          local stem = vim.fn.fnamemodify(path, ":t:r")
          local out = dir .. "/" .. stem
          local cc = ft == "cpp" and "g++" or "gcc"
          local std = ft == "cpp" and "-std=gnu++20" or "-std=gnu17"
          local inc = vim.fn.stdpath("config") .. "/include"

          local cmd = { cc, "-O0", "-g3", std, "-Wall", "-Wextra", "-DLOCAL", "-I" .. inc, "-o", out, path }
          local r = vim.system(cmd, { text = true }):wait()
          if r.code ~= 0 then
            return vim.notify("Compile failed:\n" .. (r.stderr or ""), vim.log.levels.ERROR)
          end

          local stdin
          for _, n in ipairs({ "input.txt", "in.txt", "stdin.txt" }) do
            if vim.fn.filereadable(dir .. "/" .. n) == 1 then
              stdin = dir .. "/" .. n
              break
            end
          end

          local dap = require("dap")
          dap.run({
            type = "codelldb",
            request = "launch",
            name = "CP debug " .. stem,
            program = out,
            cwd = dir,
            stopOnEntry = false,
            args = {},
            console = "integratedTerminal",
            -- codelldb's launch schema uses `stdinFile` to pipe a file on
            -- stdin (NOT `stdio`, which isn't a recognized field).
            stdinFile = stdin,
          })
        end,
        desc = "CP: compile -g & debug (input.txt on stdin)",
      },
    },
  },
}
