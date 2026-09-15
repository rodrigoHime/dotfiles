{ pkgs, username, ... }:

# Shared by every machine, regardless of how Homebrew is handled there
# (see darwin/personal-homebrew.nix vs darwin/work-homebrew.nix).
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
