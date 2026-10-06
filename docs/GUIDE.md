# User guide

_Work in progress — filled in as each phase of the setup lands._

> Prefer a browsable version? Open [`docs/guide.html`](guide.html) in a browser for the same content with navigation, a cheat-sheet, and dark mode.

## What this is

A declarative, version-controlled macOS setup. Instead of clicking
through System Settings and `brew install`-ing things one at a time,
everything is described in `.nix` files in this repo, and one command
(`sudo darwin-rebuild switch`, or just `switch`) makes your Mac match what's described.

## Everyday commands

| I want to...                          | Command |
|----------------------------------------|---------|
| Apply changes after editing a `.nix` file | `switch` (a shell alias for `sudo darwin-rebuild switch --flake "$HOME/<repo folder>#$DOTFILES_TARGET"` - the repo folder (`~/Projetos/dotfiles` on the personal Mac, `~/Projects/dotfiles` on the work Mac) and `$DOTFILES_TARGET` are both set correctly per-machine automatically; darwin-rebuild needs sudo to apply system-level changes) |
| See what would change, without applying | `darwin-rebuild build --flake "$HOME/<repo folder>#$DOTFILES_TARGET"` then diff `result` |
| Update package versions (nixpkgs, home-manager, etc.) | `nix flake update` (inside the repo), then `switch` |
| Share changes with another machine | `git add -A && git commit -m "..." && git push`, then on the other machine `git pull && switch` |
| Add a GUI app (personal machine) | Add its cask name to `darwin/personal-homebrew.nix` under `homebrew.casks`, then `switch` |
| Add a GUI app (work machine) | Add its cask name to `darwin/work-homebrew.nix` under `homebrew.casks` - only adds, never removes anything else - then `switch` |
| Add a CLI tool (both machines) | Add its package name to `home/home.nix` under `home.packages`, then `switch` |
| Pick up a changed tmux setting | `switch`, then **restart the tmux server** (`tmux kill-server` from outside tmux, open a fresh session). tmux reads its config once, when the server starts; `prefix` `r` only re-sources the file |
| Rebuild can't find a file I just created | `git add` it first. A flake only sees files git knows about, even untracked-but-present ones are invisible to it |

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
ourselves, on top of LazyVim's defaults (snacks.nvim's Explorer and Picker,
gitsigns, trouble, etc. - all included by LazyVim's core, nothing extra needed):

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
here. (The repo's folder differs per machine - `~/Projetos/dotfiles` on the
personal Mac, `~/Projects/dotfiles` on the work Mac - so it is the
`dotfilesDir` setting in `flake.nix`, passed to both this file and the
`switch` alias. Clone somewhere else and you have to change it there.)

## Neovim as an IDE: navigation, debugging, testing, tasks, GitHub

Added 2026-09-29 on top of everything above. File tree navigation and
changed-files diff review were already covered (see the table below) -
these extras round out the rest of what an IDE usually does.

**Already there before this addition - no new plugins needed:**

| Want | Keys | What it is |
|---|---|---|
| Browse the project as a tree | `<leader>e` (root dir) / `<leader>E` (cwd) - also opens automatically when you run `nvim <a-directory>` (e.g. `nvim .`), alongside the dashboard | snacks.nvim Explorer - part of LazyVim's core, git-status glyphs on changed files |
| See every changed file + its diff | `<leader>gd` | Diffview - a changed-files tree panel next to the diff, `plugins/git.lua` |
| File history / repo history | `<leader>gh` / `<leader>gH` | Diffview |
| Quick diff preview, no panel | `<leader>gs` | Snacks' own "Git Status" picker |
| Full git client (stage/commit/branch/stash) | `<leader>gg` | LazyGit, floating window, `plugins/git.lua` |

**New extras enabled in `home/nvim/lua/config/lazy.lua`:**

| Feature | Keys | Notes |
|---|---|---|
| Symbols outline sidebar | `<leader>cs` | Functions/classes/methods in the current file, click to jump |
| Breadcrumbs | *(shown in the winbar automatically)* | Module > class > function for the cursor position |
| Quick file bookmarks | `<leader>1`-`<leader>9` jump, `<leader>h` menu, `<leader>H` add current file | Harpoon2 - pin the handful of files you're actually working on |
| Reference highlighting | *(automatic)*, `]]`/`[[` or `<A-n>`/`<A-p>` to jump | Highlights other uses of the symbol under the cursor |
| Rename across the project | `<leader>cr` | Live preview as you type |
| Extract/inline refactors | via which-key under the LSP/refactor group | extract function/variable, inline variable |
| Run & monitor tasks (build/test/lint) | `<leader>oo` run, `<leader>ow` task list, `<leader>ot` task action | Overseer - like VS Code's `tasks.json` |
| Debugging | `<leader>db` breakpoint, `<leader>dc` continue, `<leader>di`/`<leader>dO`/`<leader>do` step into/over/out, `<leader>du` toggle the debugger UI, `<leader>dr` REPL | nvim-dap + nvim-dap-ui. Ruby (via `lang.ruby`'s nvim-dap-ruby) and JS/TS (via `lang.typescript`'s js-debug-adapter) both light up automatically now that this extra is on - not yet verified against a real breakpoint session, check your project has whatever the adapter needs (e.g. Ruby's `debug` gem) the first time you try it |
| Run tests from inside nvim | `<leader>tr` nearest, `<leader>tt` file, `<leader>tT` all files, `<leader>ts` toggle summary, `<leader>to` show output, `<leader>td` debug nearest | neotest. Ruby gets `neotest-rspec` automatically from `lang.ruby`; JS/TS gets both `neotest-jest` and `neotest-vitest` from `plugins/testing.lua` (each only activates itself when it finds its own config file in the project) |
| REST client | open a `.http` file, run a request from inside it | `util.rest` - a lightweight Postman replacement, response shown inline |
| GitHub issues & PRs | `<leader>gi`/`<leader>gI` issues, `<leader>gp`/`<leader>gP` PRs, `<leader>gr` repos | Octo.nvim - needs the `gh` CLI (now in `home/home.nix`) authenticated once: run `gh auth login` in a terminal after the next `switch` |

**One manual step this adds:** `gh auth login` (once, after the next `switch` pulls in the `gh` CLI) - Octo shells out to it for GitHub auth and API calls, and there's no way to script an interactive OAuth login from Nix.

## Day-to-day how-tos

Things that come up constantly once you're actually working in nvim and tmux.

**Revert changes in a file (nvim).** Press `<leader>gh` and wait: which-key
shows the gitsigns "hunks" menu. `R` is **Reset Buffer** (throw away every
unstaged change in the file), `r` is **Reset Hunk** (just the chunk under
the cursor). Related keys in the same menu: `s`/`S` stage a hunk/the whole
buffer, `u` undoes a stage, `p` previews a hunk inline, `b`/`B` blame the
line/buffer, `d` opens "Diff This" (against the index) and `D` the "Diff This ~" variant (against an earlier revision, per gitsigns).
Reset restores the *index* version, so anything you already staged stays.
For a true "back to the last commit, ignore staging" revert, open LazyGit
(`<leader>gg`), select the file and discard its changes there.

**Close a diff view (nvim).** "Diff This" (`<leader>ghd`) is a plain split
pair, not the Diffview tab. Close either half (`:q` / `<C-w>q`) and the
other one leaves diff mode on its own; or press `<C-w>o` in the window you
want to keep to close everything else. The Diffview panel (`<leader>gd`)
closes with `:DiffviewClose`.

**`<leader>gh` is two things.** This repo binds `<leader>gh` to Diffview's
"current file history", and LazyVim core uses the same `<leader>gh` prefix
for the hunks menu (`<leader>ghs`, `<leader>ghr`...). In practice which-key
shows the hunks menu. If Diffview's file history ever seems unreachable,
this is why; `<leader>gH` (repo history) is unaffected.

**Start on a project, or switch projects.** `nvim .` (or `nvim <folder>`)
opens the Explorer next to the dashboard automatically. On the dashboard,
`p` opens the Projects picker (folders you've opened before); from inside
nvim the same picker is `<leader>fp`. A brand-new folder just needs
`cd` + `nvim .` once.

**tmux panes.** `prefix` `|` splits side by side (new pane on the right),
`prefix` `-` splits top/bottom, both in the current directory. `prefix` `z`
zooms the current pane to fill the window and un-zooms it again; `prefix`
`x` closes the pane; `prefix` `d` detaches; `prefix` `:` opens tmux's command
prompt (`split-window -h` always works, whatever your keyboard does with
`|`). Remember the prefix is `Ctrl-a`, not tmux's default `Ctrl-b`.

**The swap-file prompt.** If nvim says *Found a swap file ... already
exists!* when you open a file, a previous nvim on that file never exited
cleanly (closed tab, sleep, killed pane). Check the dates in the prompt:
if the swap is far newer than the file's last save and you weren't
mid-edit, press `D` to delete it. Press `R` first to recover and inspect it
if you might have lost work, and `O` to open read-only. Avoid `E` unless
you're sure no other nvim has the file open. The files live in
`~/.local/state/nvim/swap/`.

## How the pieces fit: flakes and home-manager

**Flake.** `flake.nix` is the repo's entry point. Its *inputs* are the pinned
dependencies (nixpkgs, nix-darwin, home-manager); its *outputs* are the two
machine configurations (`rodrigos-macbook-pro`, `rodrigos-work-macbook`).
`flake.lock` records the exact commit of every input, which is what makes
both Macs build identical versions until you run `nix flake update`. Two
consequences worth knowing: evaluation is pure (a flake can't read `$USER`
or other environment at build time, which is why the work username has to
be written into `flake.nix`, and why `bootstrap.sh` fills it in), and a
flake only sees files git tracks (see "Rebuild can't find a file" above).

**home-manager.** nix-darwin manages the machine (macOS defaults, Homebrew
casks); home-manager manages everything under your home directory: shell,
tmux, git, the nvim config, user CLI tools. Here it runs *as a nix-darwin
module*, so one `switch` rebuilds both. `home/home.nix` imports
`zsh.nix`, `tmux.nix`, `iterm2.nix` and `nvim/nvim.nix`. Two ways to
configure something:

- `programs.<tool>` modules (`programs.tmux`, `programs.zsh`, `programs.git`,
  `programs.oh-my-posh`): typed options; home-manager generates the real
  config file from them. Search the home-manager options list for
  `programs.<tool>` first.
- Plain files via `home.file` / `xdg.configFile`: used for the nvim config
  and the iTerm2 profile. `lazy-lock.json` uses `mkOutOfStoreSymlink`
  because lazy.nvim rewrites it and Nix store paths are read-only.

Also: `home.packages` for CLI tools, `home.sessionVariables` for env vars.
The generated files in `~` are symlinks into `/nix/store`, so editing them
by hand does nothing durable: edit the `.nix` file, `switch`, restart
whatever reads the config. Every switch is a generation, so
`sudo darwin-rebuild --rollback` returns to the previous one. Leave
`home.stateVersion` alone; it isn't a version to upgrade.

## Troubleshooting

| Symptom | Check |
|---|---|
| A language server isn't attaching | `:LspInfo` in the buffer, then `:Mason` to confirm it installed |
| A plugin seems missing or stale | `:Lazy`; `:Lazy update` updates and rewrites `lazy-lock.json` |
| nvim feels generally broken | `:checkhealth` |
| Icons render as boxes | iTerm2 profile font must be the Meslo Nerd Font (`home/iterm2.nix`) |
| `prefix` `|` (or any tmux binding) does nothing | Prefix is `Ctrl-a`; release it before pressing the next key; restart the tmux server if you changed config since it started; try `prefix` `:` then `split-window -h` |
| "Found a swap file" prompt | See "The swap-file prompt" above |
| `<leader>gh` shows a hunks menu, not file history | Expected, see "`<leader>gh` is two things" above |
| Debugging/testing can't find ruby/node | Confirm they resolve on `PATH` in a terminal split; if not, add a PATH entry to `home/zsh.nix`, same pattern as `nvm` |
| `bootstrap.sh` on the work Mac asks for a username | Expected: it fills the `CHANGE_ME` placeholders in `flake.nix` (default is `whoami`), then you commit the change |

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
- [x] Neovim IDE extras: outline, breadcrumbs, Harpoon2, illuminate, rename/refactor, Overseer tasks, debugging (DAP), testing (neotest), REST client, GitHub (Octo) - plugins confirmed installed on a real launch; breakpoints, test runs and Octo not yet exercised
- [x] Explorer opens automatically for `nvim <directory>`
- [x] Troubleshooting section
- [x] Browsable guide in the repo (`docs/guide.html`)
- [x] Push to GitHub
- [ ] Verify a second-machine clone actually works (`./bootstrap.sh rodrigos-work-macbook` on the work Mac)
