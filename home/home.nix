{ pkgs, ... }:

{
  home.stateVersion = "25.05";

  home.packages = with pkgs; [
    ripgrep
    fd
    bat
    neovim  # placeholder; Phase 7 replaces this with the full LazyVim setup
  ];

  programs.git = {
    enable = true;
    # TODO: confirm this is the name you want on commits.
    userName = "Rodrigo Hime";
    userEmail = "rodrigo.hime@gmail.com";
  };

  programs.home-manager.enable = true;

  imports = [ ./zsh.nix ];
  # Future phases will add more here, e.g.:
  # imports = [ ./zsh.nix ./tmux.nix ./iterm2.nix ./nvim/nvim.nix ];
}
