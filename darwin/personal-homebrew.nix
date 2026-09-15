{ ... }:

# Personal MacBook Pro only. Homebrew itself is bootstrapped and owned
# by nix-homebrew (see flake.nix) - this block just declares what
# should be tapped/installed on top of that. GUI apps/casks live here;
# CLI tools generally go in home/home.nix via nixpkgs instead.
#
# Safe to let `cleanup` remove things here BECAUSE Nix owns this
# Homebrew install outright - do not copy this file's cleanup setting
# to the work machine (see darwin/work-homebrew.nix for why).
{
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      # cleanup = "uninstall"; # uncomment once you're confident the
      #                        # declared list is complete - it removes
      #                        # any brew/cask not listed below.
    };
    taps = [ ];
    brews = [ ];
    casks = [
      "iterm2"
      "font-meslo-lg-nerd-font"
    ];
  };
}
