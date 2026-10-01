-- Autocmds are automatically loaded on the VeryLazy event.
-- Default autocmds that are always set:
-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add your own overrides here.

-- Auto-open the Explorer sidebar when nvim is started with a directory
-- argument (e.g. `nvim .`), alongside the LazyVim dashboard rather than
-- replacing it - this file is itself loaded on the VeryLazy event (see the
-- comment above), which fires shortly after startup, so this check runs
-- once per session; wrapped in vim.schedule so snacks.nvim (which provides
-- both the Explorer and the dashboard) has finished its own startup first.
-- Plain `nvim` with no arguments is untouched and still shows the dashboard
-- on its own, with no file tree.
if vim.fn.argc() == 1 and vim.fn.isdirectory(vim.fn.argv(0)) == 1 then
  vim.schedule(function()
    require("snacks").explorer()
  end)
end
