{pkgs, ...}: {
  programs = {
    # xwayland needed for x11 / xserver support on niri for steam
    xwayland.enable = true;
    gamemode.enable = true; # Enabling optional optimisations for gaming / game-mode

    # Steam
    steam = {
      enable = true;
      # package = pkgs.millennium-steam;
      extraCompatPackages = [
        pkgs.proton-ge-bin
      ];
      gamescopeSession = {
        enable = true; # allows to boot directly into the steamdeck / big picture mode
      };
      extraPackages = with pkgs; [
        wineWowPackages.stable
        wineWowPackages.waylandFull
        winetricks
        protontricks
        # protonup-ng
        # protonup-qt
        protonup-rs
        protonplus
        mangohud
        steamcmd
      ];
    };
  };

  hardware.opentabletdriver = {
    enable = true;
    daemon.enable = true; #does't start automatically for some reason
  };

  environment.systemPackages = with pkgs; [
    ntfs3g # to run games on ntfs drives with linux - drive needs to be mounted with ntfs-3g too, to make it work
    # bottles
    lutris
    heroic
    dolphin-emu
    # wacomtablet
    # roccat-tools
  ];
}
