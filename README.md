# dotfiles

Reproducible macOS dev environment: **nix-darwin** for system config,
**Homebrew** (via `nix-homebrew`) for GUI apps, **home-manager** for
dotfiles (shell, tmux, Neovim...). Goal: clone this repo on any Mac and
run one command to get the same environment back.

Full plan: see the project's `implementation-plan.md`. Day-to-day usage:
see [`docs/GUIDE.md`](docs/GUIDE.md). Status tracker: [`docs/index.html`](docs/index.html).

## Repo layout

```
flake.nix                    entry point: 2 darwinConfigurations (personal + work)
darwin/common.nix             system settings shared by both machines
darwin/personal-homebrew.nix  Homebrew - personal machine (Nix owns it, via nix-homebrew)
darwin/work-homebrew.nix      Homebrew - work machine (company-managed, add-only)
home/home.nix                 home-manager: packages, git, zsh/tmux/iterm2 imports
docs/                         GUIDE.md and index.html status tracker
bootstrap.sh                  one-shot setup script, takes a flake target argument
```

## Two machines, one repo

This repo drives **two different Macs** with one shared set of files, via
two `darwinConfigurations` entries in `flake.nix`:

| | `rodrigos-macbook-pro` (personal) | `rodrigos-work-macbook` (work) |
|---|---|---|
| Homebrew | Bootstrapped + fully owned by Nix (`nix-homebrew`) | Company-managed build - Nix only ever *adds* declared casks/brews, never removes anything (`onActivation.cleanup` is never set here) |
| zsh / tmux / iTerm2 / Neovim | Identical, shared `home/home.nix` | Identical, shared `home/home.nix` |
| Claude Code | Manual install, not Nix-managed (see docs/GUIDE.md) | Manual install, not Nix-managed - separate login/subscription from personal |

Why Homebrew is handled so differently: the work Mac's Homebrew is a
company build that only allows approved packages. Letting Nix "own" it
the way it owns the personal machine's risks fighting whatever enforces
that policy, and - worse - `cleanup` uninstalling something IT requires
if it's ever turned on. So on that machine, Nix treats Homebrew as
"IT's, hands off": it can guarantee a few extra tools are present, but
never touches anything already there.

**Before the first activation on the work Mac**, edit `flake.nix` and
replace both `"CHANGE_ME"` placeholders with your actual macOS username
there (run `whoami` on that machine to get it).

> **Note:** the flake reference (`...#rodrigos-macbook-pro`) is quoted in every
> command above on purpose - zsh's extended globbing treats a bare `#` as a
> glob operator and fails with "no matches found" otherwise.

## First-time setup on a Mac

Pick the flake target for that machine: `rodrigos-macbook-pro`
(personal) or `rodrigos-work-macbook` (work - **edit `flake.nix` first**
and replace the two `"CHANGE_ME"` placeholders with `whoami`'s output on
that machine, or activation will fail).

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
3. **Activate this config** (personal machine shown, swap the target
   name for work):
   ```
   cd ~/Projetos/dotfiles
   sudo /nix/var/nix/profiles/default/bin/nix run nix-darwin -- switch --flake "$HOME/Projetos/dotfiles#rodrigos-macbook-pro"
   ```
   (The absolute path is because `sudo` doesn't inherit your shell's
   `PATH`, so plain `sudo nix ...` fails with "command not found" even
   right after installing.) First run takes a while. After this,
   `darwin-rebuild` itself will be on your `PATH`.

Or just run `./bootstrap.sh <target>` (e.g. `./bootstrap.sh
rodrigos-macbook-pro`), which does steps 1-3 for you. The target is a
required argument on purpose - the two configs handle Homebrew very
differently, so there's no safe default to fall back on.

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
```
If this is the work Mac, edit `flake.nix` first and replace both
`"CHANGE_ME"` placeholders with `whoami`'s output there. Then:
```
./bootstrap.sh rodrigos-macbook-pro     # personal
./bootstrap.sh rodrigos-work-macbook    # work
```
`bootstrap.sh` installs Xcode CLT + Nix, then activates the target you
gave it. The two `darwinConfigurations` names are just labels in the
flake (unrelated to the actual hostname) - what differs between them is
entirely in `darwin/personal-homebrew.nix` vs `darwin/work-homebrew.nix`
(see "Two machines, one repo" above), everything else in this repo is
identical on both.

## Keeping machines in sync

Once activated once, the `switch` shell alias (from `home/zsh.nix`)
picks the right target automatically on whichever machine you're on:
```
# edit a .nix file
switch                       # same as: darwin-rebuild switch --flake "$HOME/Projetos/dotfiles#$DOTFILES_TARGET"
git add -A && git commit -m "..."
git push
```
On the other machine, before you start editing there:
```
git pull
switch
```
That `switch` matters even if you didn't edit anything locally — someone
(past-you, on the other machine) may have changed the pinned package
versions in `flake.lock`, and `switch` is what actually applies them.
Package/dotfile changes always sync across machines this way; Homebrew
state on the work Mac never does (by design — see above).

**Don't commit secrets** (API keys, SSH private keys, tokens) into this
repo even though it's private — if you need those managed declarativley
later, that's a separate tool (e.g. `agenix` or `sops-nix`), not plain
Nix files. Ask if/when you want that set up.

## Status

This repo is being built up in phases — see `docs/index.html` for what's
done vs. pending. Currently: bootstrap skeleton (flake + nix-darwin +
home-manager wiring) and Homebrew/iTerm2 declaration are in place and
ready to activate; shell, tmux, and Neovim configuration are next.
