{ pkgs, username, ... }:

{
  # Let `nix` commands (and flakes) work without extra CLI flags.
  nix.settings.experimental-features = "nix-command flakes";

  # Nix itself is installed & upgraded by the Determinate Nix installer
  # (see README), not by nix-darwin -> avoid nix-darwin fighting it.
  nix.enable = false;

  system.primaryUser = username;

  users.users.${username} = {
    home = "/Users/${username}";
  };

  # Homebrew is bootstrapped by nix-homebrew (see flake.nix); this block
  # just declares what should be tapped/installed. GUI apps/casks live
  # here; CLI tools generally go in home/home.nix via nixpkgs instead.
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

  environment.variables.HOMEBREW_NO_ANALYTICS = "1";

  # Minimal system-wide packages. Most CLI tools should go in
  # home/home.nix instead, so they're tied to the user, not the system.
  environment.systemPackages = with pkgs; [
    git
    curl
    wget
  ];

  # Bump only when nix-darwin's release notes tell you to.
  system.stateVersion = 6;
  nixpkgs.hostPlatform = "aarch64-darwin";
}
