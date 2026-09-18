{ pkgs, ... }:

{
  # ── Shell: zsh + oh-my-zsh (plugins/framework) + oh-my-posh (prompt) ──
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      # No oh-my-zsh theme - oh-my-posh below owns the prompt.
      theme = "";
      plugins = [
        "git"
        "macos"
        "colored-man-pages"
        "command-not-found"
      ];
    };

    shellAliases = {
      ll = "ls -lah";
      g = "git";
      gs = "git status";
      gd = "git diff";
      vim = "nvim";
      vi = "nvim";
      # $DOTFILES_TARGET is set per-machine by flake.nix (mkHomeManager),
      # so this one alias works correctly on either machine.
      switch = "sudo darwin-rebuild switch --flake \"$HOME/Projetos/dotfiles#$DOTFILES_TARGET\"";
      # Ported from the pre-existing ~/.zshrc (kept as ~/.zshrc.backup
      # after the first real activation) - your call, not ours.
      cc = "claude --dangerously-skip-permissions";
    };

    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };

    # Anything that isn't a plugin/alias/env var - plain zsh appended to
    # the end of .zshrc. Most of this block was ported from the
    # pre-existing ~/.zprofile / ~/.zshrc (see ~/.zprofile.backup and
    # ~/.zshrc.backup after the first activation moved them aside) -
    # nix-darwin's homebrew module doesn't set any of this up for you.
    initContent = ''
      # Homebrew's own shellenv (PATH/MANPATH/etc. for everything brew
      # installs) - nix-darwin's homebrew module doesn't do this for you.
      eval "$(/opt/homebrew/bin/brew shellenv)"

      # nvm (installed via the Homebrew formula declared in
      # darwin/personal-homebrew.nix). Guarded with `-s` checks, so this
      # is a harmless no-op on any machine where it isn't installed at
      # this path (e.g. the work machine, for now).
      export NVM_DIR="$HOME/.nvm"
      [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
      [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

      # User-local installs, yarn's global bin, JetBrains Toolbox's
      # per-app command-line launcher shims.
      export PATH="$HOME/.local/bin:$PATH"
      export PATH="$PATH:$HOME/.yarn/bin"
      export PATH="$PATH:$HOME/Library/Application Support/JetBrains/Toolbox/scripts"

      # Option+Tab accepts the current autosuggestion. Needs a matching
      # iTerm2 profile key mapping (Option+Tab -> Send Hex Code
      # "0x1b 0x09") - that's a one-time manual step in iTerm2
      # Preferences, documented in docs/GUIDE.md; Nix can't set it for
      # you the way it can the rest of the profile.
      bindkey '^[^I' autosuggest-accept

      # Keep history generous and shared across panes/sessions.
      HISTSIZE=50000
      SAVEHIST=50000
      setopt SHARE_HISTORY
      setopt HIST_IGNORE_DUPS
    '';
  };

  # Prompt (renders the theme below; oh-my-zsh's own theme is disabled).
  # Using your own "peru" theme (home/oh-my-posh/peru.omp.json, ported
  # from ~/.config/oh-my-posh/peru.omp.json which the activation never
  # touched) instead of a stock theme name.
  programs.oh-my-posh = {
    enable = true;
    enableZshIntegration = true;
    configFile = ./oh-my-posh/peru.omp.json;
  };

  # Fuzzy find (Ctrl+R history, Ctrl+T files) + a smarter `cd`.
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
}
