{ config, ... }:

{
  # iTerm2 "Dynamic Profile": a JSON file iTerm2 watches and reloads
  # automatically, so the profile below is declared here rather than
  # clicked together in Preferences. Select it once in iTerm2 ->
  # Preferences -> Profiles -> "dotfiles" -> set as default (Nix can't
  # set iTerm2's *default* profile, that's an app-level preference).
  home.file."Library/Application Support/iTerm2/DynamicProfiles/dotfiles.json".text = builtins.toJSON {
    Profiles = [
      {
        Guid = "dotfiles-default-profile";
        Name = "dotfiles";
        # Requires the font-meslo-lg-nerd-font cask (darwin/configuration.nix).
        # If glyphs look wrong, check the exact family name in Font Book
        # and fix it here, or set it manually in iTerm2 Preferences.
        "Normal Font" = "MesloLGSNerdFontMono-Regular 13";
        "Use Non-ASCII Font" = false;
        "Unlimited Scrollback" = true;
        "Scrollback Lines" = 10000;
        "Silence Bell" = true;
        "Terminal Type" = "xterm-256color";
        "Blinking Cursor" = false;
        "Cursor Type" = 1; # vertical bar
        "Horizontal Spacing" = 1;
        "Vertical Spacing" = 1;
      }
    ];
  };
}
