{ pkgs, ... }:

{
  home.stateVersion = "25.05";

  home.packages = with pkgs; [
    ripgrep # also used by Telescope's live grep
    fd      # also used by Telescope's find files
    bat
  ];

  programs.git = {
    enable = true;
    # TODO: confirm this is the name you want on commits.
    userName = "Rodrigo Hime";
    userEmail = "rodrigo.hime@gmail.com";
    # TODO: this is shared across BOTH machines as written, so work
    # commits would show this personal email too. If you want a
    # different identity on the work machine, home-manager supports
    # conditional includes, e.g.:
    #   includes = [{ condition = "gitdir:~/work/"; contents.user.email = "..."; }];
    # Ask and we'll wire this up once you know which work paths/email
    # should trigger it.
  };

  programs.home-manager.enable = true;

  imports = [ ./zsh.nix ./tmux.nix ./iterm2.nix ./nvim/nvim.nix ];
}
