{pkgs, ...}: {
  programs = {
    # xwayland needed for x11 / xserver support on niri for steam
    xwayland.enable = true;
    gamemode.enable =
      true; # Enabling optional optimisations for gaming / game-mode

    # Troubleshooting for steamvr not detecting hardware
    # Enable git-lfs to use hand trackers in VR
    # hardware.steam-hardware = {
    #   enable = true;
    # };

    # Steam
    steam = {
      enable = true;
      # package = pkgs.callPackage pkgs.millennium { };
      # package = pkgs.steam-millennium; # inputs.millennium.packages.${pkgs.stdenv.hostPlatform.system}.default; # pkgs.millennium; # to use custom steam client - comment out to use default steam package
      extraCompatPackages = [
        # Setting up directory in which protonup should store its' proton-ge versions - run 'protonup' command in console afterwards to initialize
        # Install proton-ge
        # could also be done via home-manager - view vimjoyer gaming video
        pkgs.proton-ge-bin
      ];
      gamescopeSession = {
        # allows to boot directly into the steamdeck / big picture mode
        enable = true;
      };
    };
  };

  hardware.opentabletdriver = {
    enable = true;
    daemon.enable = true; #does't start automatically for some reason
  };

  environment.systemPackages = with pkgs; [
    wineWowPackages.stable
    wineWowPackages.waylandFull
    winetricks
    protontricks
    # protonup-ng
    # protonup-qt
    protonup-rs
    protonplus
    bottles
    lutris
    heroic
    mangohud
    steamcmd
    ntfs3g # to run steam games on ntfs drives with linux - drive needs to be mounted with ntfs-3g too, to make it work
    dolphin-emu
    # wacomtablet
    # roccat-tools
  ];
}
