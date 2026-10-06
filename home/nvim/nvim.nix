{ pkgs, config, dotfilesDir, ... }:

{
  home.packages = with pkgs; [
    neovim
    lazygit # backs lua/plugins/git.lua's <leader>gg
  ];

  # Symlinks the repo's init.lua/lua tree straight into ~/.config/nvim,
  # so editing "the real config" and editing this repo are the same
  # files. Read-only (points into the Nix store) - fine here, since you
  # only ever hand-edit these through the repo anyway, never through
  # nvim itself.
  xdg.configFile."nvim/init.lua".source = ./init.lua;
  xdg.configFile."nvim/lua" = {
    source = ./lua;
    recursive = true;
  };

  # Pins every plugin to the exact commit lazy.nvim resolved on first
  # launch - the nvim-plugin equivalent of flake.lock. Deliberately
  # NOT a regular store symlink like the two above: lazy.nvim itself
  # rewrites this file whenever you run `:Lazy update`, and the Nix
  # store is read-only, so a normal symlink would make that fail with
  # a permission error. mkOutOfStoreSymlink instead points straight at
  # the repo file on disk (dotfilesDir, set per machine in flake.nix,
  # since the checkout path differs between the machines), so
  # `:Lazy update` writes directly into the tracked file - `git diff`
  # shows exactly what changed, `git checkout` reverts it, same as any
  # other file here.
  xdg.configFile."nvim/lazy-lock.json".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/${dotfilesDir}/home/nvim/lazy-lock.json";
}
