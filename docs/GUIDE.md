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

## One-time manual steps (Nix can't do these for you)

A couple of things live at the macOS app-preferences level, outside
anything a `.nix` file can reach - do these once, by hand, after the
first `switch`:

- **Set the "dotfiles" iTerm2 profile as default.** iTerm2 ->
  Preferences -> Profiles -> select "dotfiles" -> "Other Actions..." ->
  "Set as Default". Nix declares the profile (`home/iterm2.nix`) but
  can't reach into iTerm2's own app-level default-profile setting.
- **Option+Tab to accept a zsh autosuggestion.** iTerm2 -> Preferences
  -> Profiles -> "dotfiles" -> Keys -> Key Mappings -> + -> press
  Option+Tab for the shortcut -> Action: "Send Hex Code" -> value
  `0x1b 0x09`. The zsh side of this (`bindkey '^[^I' autosuggest-accept`)
  is already wired up in `home/zsh.nix`; only the iTerm2-side key
  mapping needs this one manual click, since iTerm2's dynamic-profile
  format for key mappings is obscure enough that it wasn't worth
  guessing at from here.

## Shell (zsh + oh-my-posh): ported from your old dotfiles

The first real `switch` moved your pre-existing `~/.zshrc` and
`~/.zprofile` aside to `~/.zshrc.backup` / `~/.zprofile.backup` (nothing
was deleted). Everything worth keeping from them is now declared in
`home/zsh.nix` instead:

- Homebrew's `shellenv` (PATH/MANPATH for everything `brew` installs) -
  nix-darwin's homebrew module doesn't set this up on its own.
- `nvm` setup (also declared as a Homebrew formula in
  `darwin/personal-homebrew.nix`, since it backs this).
- PATH entries for `~/.local/bin`, yarn's global bin, and JetBrains
  Toolbox's per-app launcher shims.
- The `cc = "claude --dangerously-skip-permissions"` alias.
- Your own oh-my-posh theme (`home/oh-my-posh/peru.omp.json`, copied in
  from `~/.config/oh-my-posh/peru.omp.json`) instead of a stock theme.

Left out on purpose (dead weight, not because Nix couldn't do it): the
disabled Powerlevel10k instant-prompt block and `~/.p10k.zsh` source
(superseded by oh-my-posh), the oh-my-zsh scaffolding comments (`programs.zsh.oh-my-zsh`
handles that natively), and a note in the old `.zshrc` about a hardcoded
`GITHUB_TOKEN` that had already been deliberately removed - nothing to
port there, just history.

The `.backup` files aren't managed by Nix and never will be - they're
yours to read through and delete whenever you're confident nothing else
in them is worth carrying over.

## Two machines, one repo

This repo drives both your personal MacBook Pro and your work MacBook.
Almost everything is shared (`home/home.nix` and everything it imports -
zsh, tmux, iTerm2, Neovim). Homebrew is handled the *same, hands-off* way
on both machines: `darwin/personal-homebrew.nix` and
`darwin/work-homebrew.nix` each just add the casks/brews declared in
that file to whatever Homebrew is already on the machine - Nix never
takes ownership of Homebrew itself and is never allowed to remove
anything (see comments in either file for why, and never set
`onActivation.cleanup` to "uninstall"/"zap").

(Personal used to be owned by `nix-homebrew` - dropped after its
auto-migration couldn't cleanly adopt the pre-existing install, hitting
an already-there `Library/Taps` it refused to touch. Rather than fight
that, personal now works exactly like work: existing Homebrew stays
exactly as it is, Nix only adds on top.) Full reasoning in the project's
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

**Web dev + Ruby/Rails LSP, enabled:** `home/nvim/lua/config/lazy.lua`
now imports LazyVim's official extras for the stack you asked for:

| Extra | Covers |
|---|---|
| `lang.typescript` | JavaScript, TypeScript, JSX/TSX - via `vtsls` |
| `lang.tailwind` | Tailwind CSS class IntelliSense (harmless if a project doesn't use it) |
| `lang.json` | `package.json`/`tsconfig.json`/etc. + schema validation |
| `lang.ruby` | Ruby + Rails - `ruby_lsp` (default) + `rubocop` formatting + `erb-formatter` for Rails views |
| `linting.eslint` | JS/TS linting |
| `formatting.prettier` | Formats JS/TS/CSS/HTML/JSON/Markdown/YAML |

Plain HTML and CSS don't have their own LazyVim extra (there's no
`lang.html`/`lang.css`) - those two language servers (`html`, `cssls`)
are instead declared directly in `home/nvim/lua/plugins/web.lua`,
following LazyVim's own documented pattern for adding a server it
doesn't already wire up. Every LSP/formatter/linter above installs
itself automatically via Mason the first time you open a matching file
- no extra setup needed beyond `switch` and launching `nvim` once.

**One thing this doesn't cover:** these extras configure *Neovim's*
side (the language servers, formatters, linters) - they don't install
Ruby itself. Ruby/Rails development also needs an actual Ruby runtime
on `PATH` (plus `bundler`/`rails`), which is a separate decision (Nix's
own `ruby` package vs. a version manager like `rbenv`/`asdf` vs.
Homebrew's `ruby` formula) - ask and we'll wire up whichever you'd
prefer.

**Adding another language later:** same pattern - add a line like
`{ import = "lazyvim.plugins.extras.lang.<name>" }` to the `spec` table
in `home/nvim/lua/config/lazy.lua`, next to the ones already there.

**Plugin versions are pinned too:** `flake.lock` pins Nix/nixpkgs/
home-manager, and `home/nvim/lazy-lock.json` pins the exact commit of
every one of the 35 nvim plugins (confirmed on first real launch -
LazyVim's own core, blink.cmp, treesitter, mason, etc., all present and
up to date). Unlike `init.lua`/`lua` (plain read-only symlinks into the
Nix store), `lazy-lock.json` is wired up with `mkOutOfStoreSymlink`
pointing straight at the repo file on disk - because `lazy.nvim`
rewrites this file itself whenever you run `:Lazy update`, and a normal
store symlink is read-only, which would make that update fail. With
the out-of-store symlink, `:Lazy update` writes directly into the
tracked file: `git diff` shows exactly which plugins moved, `git
checkout home/nvim/lazy-lock.json` reverts it, `git add -A && git
commit` locks in a deliberate upgrade - same workflow as any other file
here. (This does assume the repo lives at `~/Projetos/dotfiles` - true
on both machines per this project's own convention.)

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
