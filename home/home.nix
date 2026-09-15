{ pkgs, ... }:

{
  home.stateVersion = "25.05";

  home.packages = with pkgs; [
    ripgrep
    fd
    fzf
    bat
  ];

  programs.git = {
    enable = true;
    # TODO: confirm this is the name you want on commits.
    userName = "Rodrigo Hime";
    userEmail = "rodrigo.hime@gmail.com";
  };

  programs.home-manager.enable = true;

  # Future phases will add imports here, e.g.:
  # imports = [ ./zsh.nix ./tmux.nix ./iterm2.nix ./nvim/nvim.nix ];
}
