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

> **Note:** the flake reference (`...#rodrigos-macbook-pro`) is quoted in every
> command above on purpose - zsh's extended globbing treats a bare `#` as a
> glob operator and fails with "no matches found" otherwise.

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
   sudo /nix/var/nix/profiles/default/bin/nix run nix-darwin -- switch --flake "$HOME/Projetos/dotfiles#rodrigos-macbook-pro"
   ```
   (The absolute path is because `sudo` doesn't inherit your shell's
   `PATH`, so plain `sudo nix ...` fails with "command not found" even
   right after installing.) First run takes a while (downloads
   Homebrew, iTerm2, etc.). After this, `darwin-rebuild` itself will be
   on your `PATH`.

Or just run `./bootstrap.sh`, which does steps 1-3 for you.

## Making changes afterwards

Edit a `.nix` file, then:

```
darwin-rebuild switch --flake "$HOME/Projetos/dotfiles#rodrigos-macbook-pro"
```

Commit once you're happy with the result:

```
git add -A && git commit -m "..."
```

## Push this to GitHub (so machines can sync)

Right now this repo is only local to this Mac — a `git commit` gives you
history, but nothing syncs between machines until it has a remote.

1. Create an empty repo on GitHub (no README/license — this repo already
   has files), e.g. `rodrigohime/dotfiles`, **private** recommended since
   it will contain machine-specific details.
2. Point this repo at it and push:
   ```
   cd ~/Projetos/dotfiles
   git remote add origin git@github.com:<you>/dotfiles.git   # or the https:// URL
   git branch -M main
   git push -u origin main
   ```
   (Uses whatever git auth is already set up in your Terminal — an SSH
   key added to GitHub, or `gh auth login` if you use the GitHub CLI.)

## New machine

```
git clone git@github.com:<you>/dotfiles.git ~/Projetos/dotfiles
cd ~/Projetos/dotfiles
./bootstrap.sh
```
`bootstrap.sh` installs Xcode CLT + Nix, then runs
`darwin-rebuild switch --flake .#rodrigos-macbook-pro` — the same
`darwinConfigurations` name is reused across machines on purpose (it's
just a label in the flake, unrelated to the actual hostname), so the
exact same flake works unmodified on a second Mac. If you later want
per-machine differences (e.g. a laptop vs. a desktop config), that's a
second `darwinConfigurations."<name>"` entry in `flake.nix` sharing most
of the same modules — ask and we'll split it out when you get there.

## Keeping machines in sync

The loop, on whichever machine you're editing on:
```
# edit a .nix file
darwin-rebuild switch --flake "$HOME/Projetos/dotfiles#rodrigos-macbook-pro"
git add -A && git commit -m "..."
git push
```
On the other machine, before you start editing there:
```
git pull
darwin-rebuild switch --flake "$HOME/Projetos/dotfiles#rodrigos-macbook-pro"
```
That last `switch` matters even if you didn't edit anything locally —
someone (past-you, on the other machine) may have changed the pinned
package versions in `flake.lock`, and `switch` is what actually applies
them.

**Don't commit secrets** (API keys, SSH private keys, tokens) into this
repo even though it's private — if you need those managed declarativley
later, that's a separate tool (e.g. `agenix` or `sops-nix`), not plain
Nix files. Ask if/when you want that set up.

## Status

This repo is being built up in phases — see `docs/index.html` for what's
done vs. pending. Currently: bootstrap skeleton (flake + nix-darwin +
home-manager wiring) and Homebrew/iTerm2 declaration are in place and
ready to activate; shell, tmux, and Neovim configuration are next.
