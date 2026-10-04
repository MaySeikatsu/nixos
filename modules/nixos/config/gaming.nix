{
  pkgs,
  lib,
  config,
  ...
}: let
  on = config.my.gaming.enable; # toggle: modules/nixos/profiles.nix
in {
  boot.kernelModules = lib.mkIf on ["ntsync"]; # Wine but kernel level / performance boost

  programs = {
    # xwayland needed for x11 / xserver support on niri for steam
    xwayland.enable = true;
    gamemode.enable = on; # Enabling optional optimisations for gaming / game-mode

    # Steam
    steam = {
      enable = on;
      # package = pkgs.millennium-steam;
      extraCompatPackages = [
        pkgs.proton-ge-bin
      ];
      gamescopeSession = {
        enable = true; # allows to boot directly into the steamdeck / big picture mode
      };
      extraPackages = with pkgs; [
        wineWow64Packages.stable
        wineWow64Packages.waylandFull
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

  environment.systemPackages = with pkgs;
    [
      ntfs3g # to run games on ntfs drives with linux - drive needs to be mounted with ntfs-3g too, to make it work
    ]
    ++ lib.optionals on [
    bottles
    lutris
    heroic
    dolphin-emu
    mame
    retroarch
    pegasus-frontend
    widelands
    protontricks # was in configuration-shared.nix
    # wacomtablet
    # roccat-tools
  ];
}
