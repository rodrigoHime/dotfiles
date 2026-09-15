{ pkgs, ... }:

{
  # ── Terminal session/pane management ──
  # (iTerm2 is the terminal app itself - see home/iterm2.nix for its
  # profile; tmux is what actually manages sessions/windows/panes.)
  programs.tmux = {
    enable = true;
    prefix = "C-a"; # classic screen-style prefix, easier on the hands than C-b
    mouse = true;
    baseIndex = 1; # windows/panes start at 1, matching keyboard numbers
    keyMode = "vi";
    terminal = "screen-256color";
    historyLimit = 50000;
    escapeTime = 0; # no delay leaving insert-ish modes (matters for nvim inside tmux)
    sensibleOnTop = true;

    plugins = with pkgs.tmuxPlugins; [
      vim-tmux-navigator # Ctrl-hjkl moves between tmux panes AND nvim splits seamlessly
      yank
      {
        plugin = resurrect;
        extraConfig = "set -g @resurrect-capture-pane-contents 'on'";
      }
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '15'
        '';
      }
    ];

    extraConfig = ''
      # Intuitive split keys, opening in the current pane's directory.
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"

      # Resize panes with prefix + H/J/K/L (repeatable).
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5

      # Reload config without restarting tmux.
      bind r source-file ~/.tmux.conf \; display-message "tmux config reloaded"

      set -g status-position top
      set -g renumber-windows on
    '';
  };
}
