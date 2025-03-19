{pkgs, inputs, ...}:
  let
    # system = "x86_64-linux";
    spicePkgs = inputs.spicetify-nix.legacyPackages."x86_64-linux";
  in
{
  programs.spicetify = {
    enable = true;
    theme = spicePkgs.themes.catppuccin;
    enabledExtensions = with spicePkgs.extensions; [
      adblockify
      hidePodcasts
      shuffle
      keyboardShortcut
      popupLyrics
      newRelease
    ];
    colorScheme = "mocha";
  };
}
