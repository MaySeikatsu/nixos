{pkgs, inputs, ...}:
  let
    # system = "x86_64-linux";
    spicePkgs = inputs.spicetify-nix.legacyPackages."x86_64-linux";
  in
{
  # Configured over normal module not home-manager
  programs.spicetify = {
    enable = true;
    # theme = spicePkgs.themes.catppuccin;
    # theme = spicePkgs.themes.text;
    # theme = spicePkgs.themes.TokyoNight;
    # theme = spicePkgs.themes.defaultDynamic;
    enabledExtensions = with spicePkgs.extensions; [
      adblockify
      hidePodcasts
      shuffle
      keyboardShortcut
      popupLyrics
      beautifulLyrics
      # simpleBeautifulLyrics
      queueTime
      history
      songStats
      featureShuffle
      phraseToPlaylist
      skipStats
      fullAppDisplay
    ];
    # Theme for catppuccin
    # colorScheme = "mocha";
    # Themes for Text
    # colorScheme = "RosePine";
    # colorScheme = "CatppuccinMocha";
    # colorScheme = "TokyoNight";
    # colorScheme = "Storm";
    # Theme for dynamic
    # colorScheme = "Base";
  };
}
