{pkgs, inputs, ...}:
  let
    # system = "x86_64-linux";
    spicePkgs = inputs.spicetify-nix.legacyPackages."x86_64-linux";
  in
{
  programs.spicetify = {
    enable = true;
    # theme = spicePkgs.themes.catppuccin;
    # theme = spicePkgs.themes.text;
    # theme = spicePkgs.themes.TokyoNight;
    theme = spicePkgs.themes.defaultDynamic;
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
    # colorScheme = "mocha";
    # colorScheme = "RosePine";
    # colorScheme = "Storm";
    colorScheme = "base";
  };
}
