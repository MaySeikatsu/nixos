{ pkgs, ... }: {
  ###GNOME EXCLUDE PACKAGES###
  environment.gnome.excludePackages = (with pkgs; [
    epiphany # web browser
    # evince # document viewer
    geary # email reader
    # gnome-characters
    gnome-music
    gnome-photos
    gnome-terminal
    gnome-tour
    totem # video player
  ]);
  ###GNOME EXCLUDE PACKAGES###
}
