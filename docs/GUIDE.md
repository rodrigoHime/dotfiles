# User guide

_Work in progress — filled in as each phase of the setup lands._

## What this is

A declarative, version-controlled macOS setup. Instead of clicking
through System Settings and `brew install`-ing things one at a time,
everything is described in `.nix` files in this repo, and one command
(`darwin-rebuild switch`) makes your Mac match what's described.

## Everyday commands

| I want to...                          | Command |
|----------------------------------------|---------|
| Apply changes after editing a `.nix` file | `darwin-rebuild switch --flake "$HOME/Projetos/dotfiles#rodrigos-macbook-pro"` |
| See what would change, without applying | `darwin-rebuild build --flake "$HOME/Projetos/dotfiles#rodrigos-macbook-pro"` then diff `result` |
| Update package versions (nixpkgs, home-manager, etc.) | `nix flake update` (inside the repo), then `darwin-rebuild switch ...` |
| Share changes with another machine | `git add -A && git commit -m "..." && git push`, then on the other machine `git pull && darwin-rebuild switch --flake "$HOME/Projetos/dotfiles#rodrigos-macbook-pro"` |
| Add a GUI app | Add its cask name to `darwin/configuration.nix` under `homebrew.casks`, then rebuild |
| Add a CLI tool | Add its package name to `home/home.nix` under `home.packages`, then rebuild |

## Coming up (filled in as each phase ships)

- [x] Shell: zsh + oh-my-zsh + oh-my-posh (`home/zsh.nix`)
- [x] Terminal: iTerm2 profile + Tmux config (`home/iterm2.nix`, `home/tmux.nix`)
- [ ] Claude Code install
- [ ] Neovim (LazyVim base): file navigation, git diff review, LSP
- [ ] Cheat-sheet of actual keybindings once they're configured
- [ ] Troubleshooting section
- [ ] Push to GitHub + verify a second-machine clone actually works
