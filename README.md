# dotfiles

Reproducible macOS dev environment: **nix-darwin** for system config,
**Homebrew** (via `nix-homebrew`) for GUI apps, **home-manager** for
dotfiles (shell, tmux, Neovim...). Goal: clone this repo on any Mac and
run one command to get the same environment back.

Full plan: see the project's `implementation-plan.md`. Day-to-day usage:
see [`docs/GUIDE.md`](docs/GUIDE.md). Status tracker: [`docs/index.html`](docs/index.html).

## Repo layout

```
flake.nix               entry point: darwin + home-manager config
darwin/configuration.nix system settings, Homebrew casks/brews/taps
home/home.nix            home-manager: packages, git, (soon: zsh/tmux/nvim)
docs/                    GUIDE.md and index.html status tracker
bootstrap.sh             one-shot setup script for a brand-new Mac
```

## First-time setup (this machine)

1. **Xcode Command Line Tools** (skip if already installed):
   ```
   xcode-select --install
   ```
2. **Install Nix** via the Determinate Systems installer (handles flakes
   for you):
   ```
   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
   ```
   Follow the prompts (it will ask for your password). Open a **new**
   terminal tab afterwards so `nix` is on your `PATH`.
3. **Activate this config**:
   ```
   cd ~/Projetos/dotfiles
   sudo nix run nix-darwin -- switch --flake .#rodrigos-macbook-pro
   ```
   First run takes a while (downloads Homebrew, iTerm2, etc.). After
   this, `darwin-rebuild` itself will be on your `PATH`.

Or just run `./bootstrap.sh`, which does steps 1-3 for you.

## Making changes afterwards

Edit a `.nix` file, then:

```
darwin-rebuild switch --flake ~/Projetos/dotfiles#rodrigos-macbook-pro
```

Commit once you're happy with the result:

```
git add -A && git commit -m "..."
```

## Status

This repo is being built up in phases — see `docs/index.html` for what's
done vs. pending. Currently: bootstrap skeleton (flake + nix-darwin +
home-manager wiring) and Homebrew/iTerm2 declaration are in place and
ready to activate; shell, tmux, and Neovim configuration are next.
