# Project context for Claude Code sessions

Read this first. It is the hand-off from earlier sessions so work can continue on any machine.
Last updated: 2026-10-06 (docs commit `99599f2`).

## What this repo is

Rodrigo Hime's reproducible macOS dev environment, rebuilt on any Mac with `git clone` + `./bootstrap.sh <target>`.

- Nix flake + nix-darwin + home-manager (Nix owns CLI tools and every dotfile)
- Homebrew for GUI apps/casks, hands-off (see Decisions)
- iTerm2 (dynamic profile) + tmux, oh-my-zsh + oh-my-posh ("peru" theme)
- Neovim on a LazyVim base, set up as a terminal IDE
- Claude Code is installed manually per machine, on purpose (not Nix-managed)

Repo path convention: `~/Projetos/dotfiles` on both machines. Remote: `github.com/rodrigoHime/dotfiles`.
Two machines, one flake:

| Flake target | Machine | Notes |
|---|---|---|
| `rodrigos-macbook-pro` | Personal Mac | Fully activated. Username `rodrigohime`. |
| `rodrigos-work-macbook` | Work Mac | Never activated. `flake.nix` still has two `"CHANGE_ME"` username placeholders; `bootstrap.sh rodrigos-work-macbook` asks for the username and fills them. |

The target names are labels, not hostnames. The `switch` zsh alias reads `$DOTFILES_TARGET`, set per machine in `flake.nix`.

## Repo map

```
flake.nix / flake.lock       entry point, two darwinConfigurations
darwin/common.nix            shared nix-darwin settings
darwin/personal-homebrew.nix add-only casks/brews (iterm2, Meslo Nerd Font, nvm)
darwin/work-homebrew.nix     add-only, company-managed Homebrew
home/home.nix                home-manager entry (git identity, gh CLI, packages)
home/zsh.nix                 oh-my-zsh, oh-my-posh, fzf, zoxide, aliases, PATH, nvm
home/tmux.nix                prefix C-a, vi keys, resurrect/continuum, vim-tmux-navigator
home/iterm2.nix              iTerm2 dynamic profile
home/oh-my-posh/peru.omp.json
home/nvim/                   LazyVim config: init.lua, lua/config/*, lua/plugins/*,
                             nvim.nix, lazy-lock.json (out-of-store symlink)
docs/index.html              visual status tracker
docs/guide.html, GUIDE.md    usage guide (HTML and Markdown, keep in sync)
bootstrap.sh                 one-shot setup, requires a target argument
README.md                    quick start
```

Daily loop: edit, then `switch` (alias for `sudo darwin-rebuild switch --flake "$HOME/Projetos/dotfiles#$DOTFILES_TARGET"`), commit, push.

## Decisions already made (do not reopen without asking)

- LazyVim is the Neovim base, customized by layering our own plugins/keymaps.
- Nix + home-manager manages everything, dotfiles included.
- Homebrew is hands-off on BOTH machines: plain `homebrew.enable = true`, add-only, `onActivation.cleanup` never set. `nix-homebrew` was tried and dropped (it could not adopt the existing `/opt/homebrew`). Work Mac uses a company-managed Homebrew fork.
- Claude Code is not Nix-managed (auth is per-machine; it updates too fast to pin).
- Docs are plain files in the repo. Two hosted Claude Artifacts mirror the tracker and the guide; they are regenerated on request, not automatically.
- The work username lives in `flake.nix` because flakes evaluate purely. `bootstrap.sh` fills it by prompting (default `whoami`) and does not commit the change.
- Explorer auto-opens for `nvim <folder>` (plain `nvim` shows only the dashboard). Implemented as top-level code + `vim.schedule` in `lua/config/autocmds.lua`, because that file loads on `VeryLazy`, after `VimEnter`.

## Gotchas learned by running things for real

- `darwin-rebuild switch` does not self-elevate: always `sudo`.
- Right after Nix install, `sudo nix` fails (PATH). Use `/nix/var/nix/profiles/default/bin/nix`.
- Quote the flake ref in interactive zsh: `"$HOME/Projetos/dotfiles#rodrigos-macbook-pro"` (`#` is a glob operator).
- A flake only sees git-tracked files: `git add` new files before `switch`.
- home-manager refuses to overwrite unmanaged dotfiles; `backupFileExtension = "backup"` moves them aside (`~/.zshrc.backup`).
- `lazy-lock.json` uses `mkOutOfStoreSymlink` so `:Lazy update` can write into the repo file. Other nvim files are read-only store symlinks.
- tmux reads its config only at server start: after changing `home/tmux.nix`, run `tmux kill-server` and start fresh.
- Current LazyVim uses snacks.nvim (Explorer + Picker). There is no telescope or neo-tree.
- `<leader>gh` is shared: gitsigns' hunk menu (b/B blame, d/D diff, p preview, r/R reset hunk/buffer, s/S stage hunk/buffer, u undo stage) and this repo's Diffview file history. which-key shows the hunk menu. Documented, not changed.
- Verify LazyVim extras/keymaps against lazyvim.org before writing config; the list changes between releases. The gitsigns `<leader>gh*` keys are not on lazyvim.org/keymaps, so they were taken from a screenshot.

## Working conditions from earlier sessions (Cowork, cloud + device bridge)

Earlier sessions ran in a cloud sandbox linked to Rodrigo's Mac. Those constraints may not apply in a normal local Claude Code session, but if they do:
- The device shell is a sandboxed Linux VM: it can edit files in the repo but cannot run macOS binaries, `sudo`, `darwin-rebuild`, `nvim` for real, or `git push` (no credentials). Rodrigo runs those in his own Terminal.
- No real `nix flake check` or `nvim` was available, so `.nix`/`.lua` edits were only brace-balance checked. Treat anything unverified as unverified.
- A stale empty `.git/index.lock` appears after `git add`; deleting it needed the delete-permission tool.
- Project docs also live in the claude.ai Project "Setup development enviroment": `claude/progress.md` (dated history) and `claude/implementation-plan.md`. They may not be visible from other sessions; this file is self-contained.

## Conventions to keep

- Check unverified assumptions with a real run before declaring done; say plainly what is unverified.
- Update `README.md`, `docs/GUIDE.md`, `docs/guide.html` and `docs/index.html` together when behavior changes. The HTML guide and Markdown guide should say the same thing.
- Commit only specific files (`git add <paths>`), one logical change per commit, imperative subject line.
- Keep Homebrew changes add-only. Never set `onActivation.cleanup`.
- Ask Rodrigo before changing a decision listed above.

## Current status (2026-10-06)

Done and activated: bootstrap, Homebrew (add-only), shell, iTerm2 profile + tmux, Neovim core (35 plugins confirmed, versions pinned), web dev + Ruby/Rails LSP extras, documentation (all four doc files current).

Installed but not yet exercised: Phase 11 Neovim extras (outline, breadcrumbs, Harpoon2, illuminate/inc-rename/refactoring, Overseer, DAP, neotest with jest/vitest/rspec, kulala REST client, Octo).

## Open items / next steps

1. `git push` commit `99599f2` from Rodrigo's own Terminal (and push this `.claude/` folder once committed).
2. Real-use checks in nvim: `nvim .` opens the Explorer; a Ruby and a JS/TS breakpoint; a test run; `gh auth login` then `<leader>gi` lists issues; Mason installs servers when opening `.rb`/`.ts`/`.html` files.
3. iTerm2 manual steps: set "dotfiles" as default profile; add the Option+Tab key mapping (Send Hex Code `0x1b 0x09`).
4. First run on the work Mac: `./bootstrap.sh rodrigos-work-macbook` (tests the username prompt and doubles as the portability check). Review `git diff flake.nix`, then commit.
5. Work git identity: wire an `includeIf` in `home/home.nix` once the work email is known (could extend the bootstrap prompt to ask for it).
6. Not yet exercised: `nix flake update` followed by a `switch`.
7. Optional: resolve the `<leader>gh` overlap (e.g. move Diffview's file history to another key) only if it bothers Rodrigo.
8. Optional: regenerate the two hosted Artifacts after meaningful doc changes.
