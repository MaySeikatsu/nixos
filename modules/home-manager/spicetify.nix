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
    theme = spicePkgs.themes.text;
    # theme = spicePkgs.themes.TokyoNight;
    # theme = spicePkgs.themes.defaultDynamic;
    
    ##Custom Theme
    #theme = {
    #  # Name of the theme (duh)
    #  name = "text-dynamic";
    #  # The source of the theme
    #  # make sure you're using the correct branch
    #  # It could also be a sub-directory of the repo
    #  src = pkgs.fetchFromGitHub {
    #    owner = "MaySeikatsu";
    #    repo = "spicetify-text-wallust/text-dynamic";
    #    rev = "main";
    #    hash = "sha256-UbiWgz+nc1kBFA3eYyNzkj+UIqlFHfCB4cmUhs1jtIA=";
    #  };
    #
    #  # Additional theme options all set to defaults
    #  # the docs of the theme should say which of these 
    #  # if any you have to change
    #  injectCss = true;
    #  injectThemeJs = true;
    #  replaceColors = true;
    #  homeConfig = true;
    #  overwriteAssets = false;
    #  additonalCss = "";
    #};
    
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
    # colorScheme = "Spotify";
    # colorScheme = "Spicetify";
    colorScheme = "RosePine";
    # colorScheme = "CatppuccinMocha";
    # colorScheme = "TokyoNight";
    # colorScheme = "Storm";
    # Theme for dynamic
    # colorScheme = "Base";
  };
}


# for custom theme:
    #customColorScheme = {
    #	text               = "D3C6AA";
    #	subtext            = "9da9a0";
    #	accent             = "E5C890";
    #	main               = "272e33";
    #	sidebar            = "272e33";
    #	player             = "272e33";
    #	card               = "272e33";
    #	shadow             = "1e2326";
    #	selected-row       = "626880";
    #	button             = "D3C6AA";
    #	button-active      = "949CBB";
    #	button-disabled    = "737994";
    #	tab-active         = "414559";
    #	notification       = "414559";
    #	notification-error = "e67e80";
    #	equalizer          = "F2D5CF";
    #	misc               = "626880";
    #}; 
