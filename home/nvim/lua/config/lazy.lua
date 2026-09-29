-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    -- add LazyVim and import its plugins (this alone gives you
    -- snacks.nvim's Explorer + Picker, gitsigns, trouble, mason+lspconfig,
    -- treesitter, etc. - all part of LazyVim's default core)
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },

    -- Web dev + Ruby/Rails language extras (LSP + formatting/linting,
    -- pre-wired by LazyVim - see docs/GUIDE.md's "Neovim" section for
    -- what each one sets up). Plain HTML/CSS language servers aren't
    -- their own LazyVim extra (no "lang.html"/"lang.css" exists) -
    -- that's handled instead by plugins/web.lua alongside these.
    { import = "lazyvim.plugins.extras.lang.typescript" }, -- JS/TS/JSX/TSX (vtsls)
    { import = "lazyvim.plugins.extras.lang.tailwind" }, -- Tailwind CSS class IntelliSense
    { import = "lazyvim.plugins.extras.lang.json" }, -- package.json/tsconfig.json/etc. + schema validation
    { import = "lazyvim.plugins.extras.lang.ruby" }, -- Ruby + Rails (ruby_lsp, rubocop, erb-formatter)
    { import = "lazyvim.plugins.extras.linting.eslint" }, -- JS/TS linting
    { import = "lazyvim.plugins.extras.formatting.prettier" }, -- JS/TS/CSS/HTML/JSON/MD/YAML formatting

    -- "Full terminal IDE" extras (added 2026-09-29 - see docs/GUIDE.md's
    -- "Neovim as an IDE" section for the keymaps each one adds). File
    -- tree (Explorer) + changed-files diff (Diffview/LazyGit) were
    -- already covered by LazyVim's core + plugins/git.lua; these round
    -- out symbol navigation, debugging, testing, tasks and GitHub.
    { import = "lazyvim.plugins.extras.editor.outline" }, -- <leader>cs - symbols outline sidebar
    { import = "lazyvim.plugins.extras.editor.navic" }, -- winbar breadcrumbs (module > class > function)
    { import = "lazyvim.plugins.extras.editor.harpoon2" }, -- <leader>h / <leader>1-9 - quick file bookmarks
    { import = "lazyvim.plugins.extras.editor.illuminate" }, -- auto-highlights other uses of the symbol under the cursor
    { import = "lazyvim.plugins.extras.editor.inc-rename" }, -- <leader>cr - live-preview rename
    { import = "lazyvim.plugins.extras.editor.refactoring" }, -- extract/inline variable & function refactors
    { import = "lazyvim.plugins.extras.editor.overseer" }, -- <leader>oo/ot/ow - run & monitor build/test/lint tasks
    { import = "lazyvim.plugins.extras.dap.core" }, -- <leader>d* - breakpoints/step/continue/REPL (nvim-dap + dap-ui)
    { import = "lazyvim.plugins.extras.test.core" }, -- <leader>t* - run tests from inside nvim (neotest)
    { import = "lazyvim.plugins.extras.util.rest" }, -- send requests from a .http file, see the response inline
    { import = "lazyvim.plugins.extras.util.octo" }, -- <leader>gi/gp/etc - GitHub issues & PRs without leaving nvim

    -- import/override with your own plugins (home/nvim/lua/plugins/*.lua)
    { import = "plugins" },
  },
  defaults = {
    -- By default, only LazyVim plugins will be lazy-loaded. Your custom
    -- plugins will load during startup.
    lazy = false,
    version = false, -- always use the latest git commit
  },
  install = { colorscheme = { "tokyonight", "habamax" } },
  checker = {
    enabled = true, -- check for plugin updates periodically
    notify = false, -- don't notify on every check
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
