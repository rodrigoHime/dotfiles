-- Plain HTML/CSS language servers - LazyVim doesn't ship a "lang.html"
-- or "lang.css" extra (only lang.typescript for JS/TS and lang.tailwind
-- for Tailwind class IntelliSense), so these are added the way
-- LazyVim's own docs recommend for any server it doesn't already wire
-- up: extend nvim-lspconfig's `opts.servers`. mason-lspconfig then
-- installs them automatically the first time a matching file is opened.
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        html = {},
        cssls = {},
      },
    },
  },
}
