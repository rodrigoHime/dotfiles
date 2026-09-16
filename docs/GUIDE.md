# User guide

_Work in progress — filled in as each phase of the setup lands._

## What this is

A declarative, version-controlled macOS setup. Instead of clicking
through System Settings and `brew install`-ing things one at a time,
everything is described in `.nix` files in this repo, and one command
(`sudo darwin-rebuild switch`, or just `switch`) makes your Mac match what's described.

## Everyday commands

| I want to...                          | Command |
|----------------------------------------|---------|
| Apply changes after editing a `.nix` file | `switch` (a shell alias for `sudo darwin-rebuild switch --flake "$HOME/Projetos/dotfiles#$DOTFILES_TARGET"` - `$DOTFILES_TARGET` is set correctly per-machine automatically; darwin-rebuild needs sudo to apply system-level changes) |
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

## Neovim (LazyVim)

`home/nvim/init.lua` and `home/nvim/lua/` are symlinked straight into
`~/.config/nvim` - editing files in this repo IS editing your live nvim
config, no separate "deploy" step. LazyVim itself (and every plugin) is
cloned by `lazy.nvim` the first time you launch `nvim` - that needs
network access and happens once, not something Nix does for you.

**Discovering keybinds:** press `<space>` (the leader key) and wait -
LazyVim's which-key pops up and shows every available keybinding grouped
by category. That's the reliable way to find things, since LazyVim's
own defaults can shift slightly between versions. A few we added
ourselves, on top of LazyVim's defaults (Telescope, neo-tree, gitsigns,
trouble, etc. - all included by LazyVim's core, nothing extra needed):

| Keys | Does |
|------|------|
| `<leader>gg` | Open LazyGit (full TUI git client) in a floating window |
| `<leader>gd` | Open Diffview (side-by-side diff of working changes) |
| `<leader>gh` | Diffview: history of the current file |
| `<leader>gH` | Diffview: history of the whole repo |
| `Ctrl+h/j/k/l` | Move between nvim splits *and* tmux panes seamlessly (vim-tmux-navigator) |

**Adding a language:** LazyVim ships official "extras" per language
(LSP + treesitter + formatting, pre-wired) - add a line like
`{ import = "lazyvim.plugins.extras.lang.typescript" }` to the `spec`
table in `home/nvim/lua/config/lazy.lua`, next to the LazyVim/plugins
imports already there. Ask and we'll wire up whichever languages you
want.

**Making plugin versions reproducible too:** right now `flake.lock`
pins Nix/nixpkgs/home-manager, but not the exact commit of each nvim
plugin - that's a separate file, `lazy-lock.json`, which `lazy.nvim`
writes to `~/.config/nvim/lazy-lock.json` after you've launched `nvim`
at least once. It doesn't exist yet. Once it does: copy it into
`home/nvim/lazy-lock.json`, add
`xdg.configFile."nvim/lazy-lock.json".source = ./lazy-lock.json;` to
`home/nvim/nvim.nix`, and commit both - from then on a second machine
gets the exact same plugin versions too, not just the exact same specs.

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
- [x] Neovim (LazyVim base): file navigation, git diff review, LSP (`home/nvim/`)
- [ ] Troubleshooting section
- [ ] Push to GitHub + verify a second-machine clone actually works
