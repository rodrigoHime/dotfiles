{
  description = "Rodrigo's macOS dev environment (nix-darwin + home-manager)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, ... }:
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
          # Both machines already had their own dotfiles (~/.zshrc etc.)
          # before this repo existed - same story as Homebrew. Rather
          # than error out (the default) or silently delete what's
          # there, move any conflicting existing file to "<name>.backup"
          # once, then home-manager takes over that path going forward.
          home-manager.backupFileExtension = "backup";
          home-manager.users.${username} = {
            imports = [ ./home/home.nix ];
            home.sessionVariables.DOTFILES_TARGET = target;
          };
        }
      ];
    in
    {
      # Personal MacBook Pro. Homebrew here is hands-off, same model as
      # the work machine - see darwin/personal-homebrew.nix for why
      # (nix-homebrew's migration couldn't cleanly adopt the existing
      # install, so we stopped fighting it).
      # Activate: darwin-rebuild switch --flake .#rodrigos-macbook-pro
      darwinConfigurations."rodrigos-macbook-pro" = nix-darwin.lib.darwinSystem {
        inherit system;
        specialArgs = { username = "rodrigohime"; };
        modules = [
          ./darwin/common.nix
          ./darwin/personal-homebrew.nix
        ] ++ mkHomeManager { username = "rodrigohime"; target = "rodrigos-macbook-pro"; };
      };

      # Work MacBook. Homebrew there is the company-managed build -
      # darwin/work-homebrew.nix deliberately skips nix-homebrew and
      # never removes anything IT installed. See that file for the
      # reasoning.
      #
      # "CHANGE_ME" below is a placeholder. `bootstrap.sh` asks for the
      # real macOS username (defaulting to `whoami`) and fills in both
      # occurrences automatically on first run against this target - see
      # the pre-flight check in bootstrap.sh. Running `darwin-rebuild
      # switch` directly instead, without ever having run bootstrap.sh
      # here, needs both "CHANGE_ME" occurrences below replaced by hand
      # first.
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
