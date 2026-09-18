{
  description = "Rodrigo's macOS dev environment (nix-darwin + home-manager)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Only used by the personal machine - see darwin/personal-homebrew.nix
    # vs darwin/work-homebrew.nix for why.
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, nix-homebrew, ... }:
    let
      system = "aarch64-darwin";

      # Shared by every machine: wires home/home.nix into home-manager
      # for the given user, and stamps which flake target this machine
      # should rebuild against (read by the `switch` shell alias in
      # home/zsh.nix, so that alias doesn't have to hardcode a name
      # that's wrong on the other machine).
      mkHomeManager = { username, target }: [
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.${username} = {
            imports = [ ./home/home.nix ];
            home.sessionVariables.DOTFILES_TARGET = target;
          };
        }
      ];
    in
    {
      # Personal MacBook Pro. Nix bootstraps + fully owns Homebrew here
      # (darwin/personal-homebrew.nix + nix-homebrew below).
      # Activate: darwin-rebuild switch --flake .#rodrigos-macbook-pro
      darwinConfigurations."rodrigos-macbook-pro" = nix-darwin.lib.darwinSystem {
        inherit system;
        specialArgs = { username = "rodrigohime"; };
        modules = [
          ./darwin/common.nix
          ./darwin/personal-homebrew.nix

          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;
              enableRosetta = false;
              user = "rodrigohime";
              mutableTaps = false;
              # This machine already had Homebrew installed before any
              # of this - nix-homebrew otherwise refuses to touch an
              # existing install. autoMigrate adopts it (keeping
              # already-installed packages) instead of demanding a
              # from-scratch one.
              autoMigrate = true;
            };
          }
        ] ++ mkHomeManager { username = "rodrigohime"; target = "rodrigos-macbook-pro"; };
      };

      # Work MacBook. Homebrew there is the company-managed build -
      # darwin/work-homebrew.nix deliberately skips nix-homebrew and
      # never removes anything IT installed. See that file for the
      # reasoning.
      #
      # TODO before the first activation on that machine: replace
      # "CHANGE_ME" below with the real macOS username (run `whoami`
      # there) - can't be filled in from here, this session isn't
      # linked to that Mac.
      # Activate: darwin-rebuild switch --flake .#rodrigos-work-macbook
      darwinConfigurations."rodrigos-work-macbook" = nix-darwin.lib.darwinSystem {
        inherit system;
        specialArgs = { username = "CHANGE_ME"; };
        modules = [
          ./darwin/common.nix
          ./darwin/work-homebrew.nix
        ] ++ mkHomeManager { username = "CHANGE_ME"; target = "rodrigos-work-macbook"; };
      };
    };
}
