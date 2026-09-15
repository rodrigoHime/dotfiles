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
| Apply changes after editing a `.nix` file | `switch` (a shell alias for `darwin-rebuild switch --flake "$HOME/Projetos/dotfiles#$DOTFILES_TARGET"` - `$DOTFILES_TARGET` is set correctly per-machine automatically) |
| See what would change, without applying | `darwin-rebuild build --flake "$HOME/Projetos/dotfiles#$DOTFILES_TARGET"` then diff `result` |
| Update package versions (nixpkgs, home-manager, etc.) | `nix flake update` (inside the repo), then `switch` |
| Share changes with another machine | `git add -A && git commit -m "..." && git push`, then on the other machine `git pull && switch` |
| Add a GUI app (personal machine) | Add its cask name to `darwin/personal-homebrew.nix` under `homebrew.casks`, then `switch` |
| Add a GUI app (work machine) | Add its cask name to `darwin/work-homebrew.nix` under `homebrew.casks` - only adds, never removes anything else - then `switch` |
| Add a CLI tool (both machines) | Add its package name to `home/home.nix` under `home.packages`, then `switch` |

## Two machines, one repo

This repo drives both your personal MacBook Pro and your work MacBook.
Almost everything is shared (`home/home.nix` and everything it imports -
zsh, tmux, iTerm2, Neovim once Phase 7 lands). The one deliberate
difference is Homebrew: `darwin/personal-homebrew.nix` lets Nix fully own
Homebrew on the personal machine; `darwin/work-homebrew.nix` treats the
work machine's company-managed Homebrew as "IT's, hands off" - it can add
declared casks/brews but is never allowed to remove anything (see
comments in that file for why). Full reasoning in the project's
`implementation-plan.md` and in `README.md`'s "Two machines, one repo"
section.

## Why Claude Code isn't managed by Nix here

It's installed manually on each machine instead of being declared in
`home/home.nix`, on purpose:

- **Auth is per-machine anyway.** The CLI binary and your login/subscription
  are separate - Nix installing the binary wouldn't force the same account
  across machines. You still run its login flow on each machine
  independently (e.g. a work account on a work Mac, personal elsewhere).
- **It ships updates fast.** Pinning it through `flake.lock` means new
  versions only land when you deliberately `nix flake update` + rebuild -
  fine for most of this setup, annoying for a tool you want to self-update.

Install it following Anthropic's normal instructions on each machine, and
log in with whichever account is right for that machine.

## Coming up (filled in as each phase ships)

- [x] Shell: zsh + oh-my-zsh + oh-my-posh (`home/zsh.nix`)
- [x] Terminal: iTerm2 profile + Tmux config (`home/iterm2.nix`, `home/tmux.nix`)
- [x] ~~Claude Code install~~ — intentionally left out of Nix management, see note below
- [ ] Neovim (LazyVim base): file navigation, git diff review, LSP
- [ ] Cheat-sheet of actual keybindings once they're configured
- [ ] Troubleshooting section
- [ ] Push to GitHub + verify a second-machine clone actually works
