#!/usr/bin/env bash
# One-shot bootstrap for a brand-new Mac. Run from an empty checkout of
# this repo at ~/Projetos/dotfiles (or wherever you cloned it).
set -euo pipefail

echo "==> 1/4 Xcode Command Line Tools"
xcode-select -p >/dev/null 2>&1 || xcode-select --install

echo "==> 2/4 Installing Nix (Determinate Systems installer)"
if ! command -v nix >/dev/null 2>&1; then
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
else
  echo "nix already installed, skipping"
fi

echo "==> 3/4 Activating nix-darwin (this will prompt for your password)"
cd "$(dirname "$0")"
sudo nix run nix-darwin -- switch --flake .#rodrigos-macbook-pro

echo "==> 4/4 Done. Restart your terminal (or open iTerm2) to pick up the new shell."
