-- Hot-reload the active colorscheme + transparency tweaks when Lazy reloads
-- the spec (e.g. when Omarchy rewrites a plugin file on theme change).
--
-- The colorscheme to apply is read from LazyVim's resolved opts (set by
-- whichever plugin file pins `LazyVim/LazyVim` opts.colorscheme = "..."),
-- with `vim.g.colors_name` as fallback. We do NOT depend on a fixed module
-- path like "plugins.theme" so this keeps working regardless of where the
-- user pins their colorscheme.
return {
  {
    name = "theme-hotreload",
    dir = vim.fn.stdpath("config"),
    lazy = false,
    priority = 1000,
    config = function()
      local transparency_file = vim.fn.stdpath("config") .. "/after/plugin/transparency.lua"

      local function resolve_colorscheme()
        -- 1) Ask LazyVim for its merged opts.
        local ok, lv = pcall(require, "lazyvim.config")
        if ok and lv then
          local opts = type(lv.opts) == "function" and lv.opts() or lv.opts
          if type(opts) == "table" and type(opts.colorscheme) == "string" then
            return opts.colorscheme
          end
          if type(lv.colorscheme) == "string" then
            return lv.colorscheme
          end
        end
        -- 2) Fallback: whatever is currently active.
        return vim.g.colors_name
      end

      vim.api.nvim_create_autocmd("User", {
        pattern = "LazyReload",
        callback = function()
          vim.schedule(function()
            local colorscheme = resolve_colorscheme()
            if not colorscheme or colorscheme == "" then
              return
            end

            -- Clear highlight state so the new theme applies cleanly.
            vim.cmd("highlight clear")
            if vim.fn.exists("syntax_on") == 1 then
              vim.cmd("syntax reset")
            end
            -- Reset background; light/dark themes will set this themselves.
            vim.o.background = "dark"

            -- Make sure the colorscheme plugin is loaded before applying.
            local loader_ok, loader = pcall(require, "lazy.core.loader")
            if loader_ok and loader.colorscheme then
              pcall(loader.colorscheme, colorscheme)
            end

            vim.defer_fn(function()
              pcall(vim.cmd.colorscheme, colorscheme)
              vim.cmd("redraw!")

              if vim.fn.filereadable(transparency_file) == 1 then
                vim.defer_fn(function()
                  pcall(vim.cmd.source, transparency_file)
                  -- Let plugins that listen on ColorScheme refresh their
                  -- highlights. We deliberately do NOT re-fire VimEnter:
                  -- many plugins gate one-time setup on it.
                  vim.api.nvim_exec_autocmds("ColorScheme", { modeline = false })
                  vim.cmd("redraw!")
                end, 5)
              end
            end, 5)
          end)
        end,
      })
    end,
  },
}
