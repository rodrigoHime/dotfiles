{ ... }:

# Personal MacBook Pro. This machine already had its own Homebrew
# install before any of this repo existed, and nix-homebrew's
# auto-migration (which takes ownership of Homebrew) hit real friction
# trying to adopt it (an existing Library/Taps it couldn't cleanly take
# over). Decision: don't fight that - treat this Homebrew the exact
# same "hands off" way as the work machine (darwin/work-homebrew.nix).
# Nix only ever ADDS the casks/brews declared below; nothing else
# already installed here is touched.
#
# NEVER set `onActivation.cleanup` to "uninstall"/"zap" - that would
# remove anything installed here that isn't declared below.
{
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true; # fine to let brew update itself here - your machine, your call
      upgrade = false;
    };
    taps = [ ];
    brews = [ ];
    casks = [
      "iterm2"
      "font-meslo-lg-nerd-font"
    ];
  };
}
