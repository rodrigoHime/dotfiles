{ ... }:

# Work MacBook only. Homebrew there is the company-managed build - this
# machine deliberately does NOT use the nix-homebrew module (which
# bootstraps + takes ownership of a fresh Homebrew install). Instead
# this just points nix-darwin's plain `homebrew` integration at
# whatever `brew` is already on PATH and only ever ADDS what's listed
# below; nothing already installed by IT is touched.
#
# NEVER set `onActivation.cleanup` here (leave it at its default,
# "none"). Setting it to "uninstall"/"zap" would remove any
# company-installed software - including required agents - that isn't
# declared in this file. This is the one setting that must never be
# copied over from darwin/personal-homebrew.nix.
{
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = false; # leave brew's own update cadence to IT/you, not us
      upgrade = false;
    };
    taps = [ ];
    brews = [ ];
    casks = [ ];
  };
}
