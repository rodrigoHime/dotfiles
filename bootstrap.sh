#!/usr/bin/env bash
# One-shot bootstrap for a brand-new Mac. Run from an empty checkout of
# this repo at ~/Projetos/dotfiles (or wherever you cloned it).
#
# Usage: ./bootstrap.sh <flake-target>
#   e.g. ./bootstrap.sh rodrigos-macbook-pro     (personal - Nix owns Homebrew)
#        ./bootstrap.sh rodrigos-work-macbook    (work - company Homebrew, untouched)
#
# The target is required on purpose, not defaulted: the two configs
# handle Homebrew very differently (see darwin/personal-homebrew.nix vs
# darwin/work-homebrew.nix), so picking the wrong one on the wrong
# machine is exactly the mistake this script should never make for you.
set -euo pipefail

TARGET="${1:-}"
if [ -z "$TARGET" ]; then
  echo "Usage: $0 <flake-target>  (e.g. rodrigos-macbook-pro or rodrigos-work-macbook)" >&2
  exit 1
fi

echo "==> 1/4 Xcode Command Line Tools"
xcode-select -p >/dev/null 2>&1 || xcode-select --install

echo "==> 2/4 Installing Nix (Determinate Systems installer)"
if ! command -v nix >/dev/null 2>&1; then
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
else
  echo "nix already installed, skipping"
fi

echo "==> 3/4 Activating nix-darwin for target '$TARGET' (this will prompt for your password)"
cd "$(dirname "$0")"
# `sudo` doesn't inherit the current shell's PATH, so `sudo nix ...` fails
# with "command not found" even right after installing - use the
# absolute path to the Nix that was just installed instead.
NIX_BIN="/nix/var/nix/profiles/default/bin/nix"
if ! command -v nix >/dev/null 2>&1 && [ ! -x "$NIX_BIN" ]; then
  echo "Could not find nix. Open a NEW terminal tab and re-run this script." >&2
  exit 1
fi
sudo "${NIX_BIN:-$(command -v nix)}" run nix-darwin -- switch --flake ".#${TARGET}"

echo "==> 4/4 Done. Restart your terminal (or open iTerm2) to pick up the new shell."
