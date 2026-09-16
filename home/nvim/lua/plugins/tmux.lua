-- Seamless Ctrl-hjkl movement between nvim splits and tmux panes.
-- Tmux side is already configured in home/tmux.nix.
return {
  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
  },
}
