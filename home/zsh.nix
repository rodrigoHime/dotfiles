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
      switch = "darwin-rebuild switch --flake \"$HOME/Projetos/dotfiles#rodrigos-macbook-pro\"";
    };

    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };

    # Anything that isn't a plugin/alias/env var - plain zsh appended to
    # the end of .zshrc.
    initContent = ''
      # Keep history generous and shared across panes/sessions.
      HISTSIZE=50000
      SAVEHIST=50000
      setopt SHARE_HISTORY
      setopt HIST_IGNORE_DUPS
    '';
  };

  # Prompt (renders the theme below; oh-my-zsh's own theme is disabled).
  programs.oh-my-posh = {
    enable = true;
    enableZshIntegration = true;
    useTheme = "jandedobbeleer";
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
