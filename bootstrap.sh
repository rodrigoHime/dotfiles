#!/usr/bin/env bash
# One-shot bootstrap for a brand-new Mac. Run from an empty checkout of
# this repo at ~/Projetos/dotfiles (or wherever you cloned it).
#
# Usage: ./bootstrap.sh <flake-target>
#   e.g. ./bootstrap.sh rodrigos-macbook-pro     (personal Mac)
#        ./bootstrap.sh rodrigos-work-macbook    (work Mac)
#
# The target is required on purpose, not defaulted: the two configs
# handle Homebrew differently (see darwin/personal-homebrew.nix vs
# darwin/work-homebrew.nix - both hands-off/add-only, but for different
# reasons), so picking the wrong one on the wrong machine is exactly the
# mistake this script should never make for you.
set -euo pipefail

TARGET="${1:-}"
if [ -z "$TARGET" ]; then
  echo "Usage: $0 <flake-target>  (e.g. rodrigos-macbook-pro or rodrigos-work-macbook)" >&2
  exit 1
fi

cd "$(dirname "$0")"

echo "==> 1/6 Pre-flight checks"

if [ "$(uname -s)" != "Darwin" ]; then
  echo "This is a macOS-only setup (nix-darwin, Homebrew, iTerm2) - refusing to run on $(uname -s)." >&2
  exit 1
fi

if [ "$(uname -m)" != "arm64" ]; then
  echo "Warning: flake.nix hardcodes system = \"aarch64-darwin\" (Apple Silicon)." >&2
  echo "This looks like an Intel Mac ($(uname -m)) - you'll likely need to change" >&2
  echo "that in flake.nix before activation will work. Continuing anyway..." >&2
fi

# The work machine's darwinConfigurations entry still has literal
# "CHANGE_ME" username placeholders until someone fills them in on that
# actual machine (can't be done from anywhere else) - this is a real
# gotcha that's already bitten us once, worth failing fast on instead of
# letting nix-darwin fail deep into evaluation with a confusing error.
if [ "$TARGET" = "rodrigos-work-macbook" ] && grep -q '"CHANGE_ME"' flake.nix; then
  echo "flake.nix still has 'CHANGE_ME' placeholders for the work machine's" >&2
  echo "username. Run 'whoami' on this Mac and replace both occurrences in" >&2
  echo "flake.nix, then re-run this script." >&2
  exit 1
fi

echo "==> 2/6 Xcode Command Line Tools"
xcode-select -p >/dev/null 2>&1 || xcode-select --install

echo "==> 3/6 Homebrew"
# nix-darwin's `homebrew` module (darwin/personal-homebrew.nix,
# darwin/work-homebrew.nix) only ever ADDS declared casks/brews to an
# existing Homebrew - it does not install Homebrew itself, and will
# abort activation with "requires homebrew installed" if there isn't
# already a *working* `brew` here. Check for that explicitly, using
# absolute paths rather than `command -v` since a brand-new install
# (or a fresh shell after one) won't have /opt/homebrew/bin on PATH yet.
find_brew() {
  if [ -x /opt/homebrew/bin/brew ]; then echo /opt/homebrew/bin/brew
  elif [ -x /usr/local/bin/brew ]; then echo /usr/local/bin/brew
  fi
}
BREW_BIN="$(find_brew || true)"

if [ -n "$BREW_BIN" ] && "$BREW_BIN" --version >/dev/null 2>&1; then
  echo "Homebrew already installed and working ($BREW_BIN), skipping"
else
  if [ -n "$BREW_BIN" ]; then
    echo "Found $BREW_BIN but it doesn't run - Homebrew looks broken."
    echo "(This happened for real once: an abandoned nix-homebrew migration"
    echo "attempt left bin/brew missing while Cellar/Taps stayed intact."
    echo "Re-running Homebrew's own installer repairs this without touching"
    echo "anything already installed.)"
  else
    echo "Homebrew not found - installing it now."
  fi
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  BREW_BIN="$(find_brew || true)"
  if [ -z "$BREW_BIN" ] || ! "$BREW_BIN" --version >/dev/null 2>&1; then
    echo "Homebrew still isn't working after running its installer. Fix that" >&2
    echo "by hand (see the installer's own output above), then re-run this script." >&2
    exit 1
  fi
fi

echo "==> 4/6 Installing Nix (Determinate Systems installer)"
if ! command -v nix >/dev/null 2>&1; then
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
else
  echo "nix already installed, skipping"
fi

echo "==> 5/6 Activating nix-darwin for target '$TARGET' (this will prompt for your password)"
# `sudo` doesn't inherit the current shell's PATH, so `sudo nix ...` fails
# with "command not found" even right after installing - use the
# absolute path to the Nix that was just installed instead.
NIX_BIN="/nix/var/nix/profiles/default/bin/nix"
if ! command -v nix >/dev/null 2>&1 && [ ! -x "$NIX_BIN" ]; then
  echo "Could not find nix. Open a NEW terminal tab and re-run this script." >&2
  exit 1
fi
sudo "${NIX_BIN:-$(command -v nix)}" run nix-darwin -- switch --flake ".#${TARGET}"

echo "==> 6/6 Done. Restart your terminal (or open iTerm2) to pick up the new shell."
