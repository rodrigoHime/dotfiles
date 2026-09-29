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
    -- Telescope, neo-tree, gitsigns, trouble, mason+lspconfig,
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
