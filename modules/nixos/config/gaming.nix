{
  pkgs,
  lib,
  config,
  ...
}: let
  on = config.my.gaming.enable; # toggle: modules/nixos/profiles.nix

  # Steam Deck UI nested in gamescope inside niri: gamescope handles game focus/fullscreen
  # itself (-e = Steam integration), so games no longer open unfocused next to Big Picture.
  # Sized to the currently focused niri output. Alternative without gamescope: the
  # commented steam window-rules in ressources/dots/niri/config.kdl
  steam-gamescope = pkgs.writeShellScriptBin "steam-gamescope" ''
    mode=$(niri msg --json focused-output 2>/dev/null \
      | ${pkgs.jq}/bin/jq -r '.modes[.current_mode] | "\(.width) \(.height) \((.refresh_rate + 500) / 1000 | floor)"')
    read -r w h r <<< "''${mode:-1920 1080 60}"

    # launched by Sunshine (sunshine_moonlight.nix): render at the Moonlight client's
    # resolution/fps, gamescope scales it to the monitor that Sunshine captures
    extra=()
    if [ -n "''${SUNSHINE_CLIENT_WIDTH:-}" ]; then
      extra=(-w "$SUNSHINE_CLIENT_WIDTH" -h "$SUNSHINE_CLIENT_HEIGHT")
      r=''${SUNSHINE_CLIENT_FPS:-$r}
    fi

    # Steam is single-instance: close a running desktop Steam first (max ~30s)
    if pgrep -x steam >/dev/null; then
      steam -shutdown
      for _ in $(seq 30); do pgrep -x steam >/dev/null || break; sleep 1; done
    fi

    exec gamescope -e -f -W "$w" -H "$h" "''${extra[@]}" -r "$r" --adaptive-sync -- steam -gamepadui "$@"
  '';
  steam-gamescope-desktop = pkgs.makeDesktopItem {
    name = "steam-gamescope";
    desktopName = "Steam (Gamescope)";
    exec = "steam-gamescope";
    icon = "steam";
    categories = ["Game"];
  };

  # pegasus-frontend's wrapper has no qtwayland plugin, and the niri/mango sessions export
  # QT_QPA_PLATFORM=wayland, which makes it abort at startup. Force X11 (xwayland is enabled).
  pegasus = pkgs.symlinkJoin {
    name = "pegasus-frontend-wrapped";
    paths = [pkgs.pegasus-frontend];
    nativeBuildInputs = [pkgs.makeWrapper];
    postBuild = ''
      wrapProgram $out/bin/pegasus-fe --set QT_QPA_PLATFORM xcb
      # launchers (fsel, the desktop menu) start the .desktop Exec, which otherwise points at
      # the unwrapped store binary: repoint it at the wrapper
      rm $out/share/applications/org.pegasus_frontend.Pegasus.desktop
      sed "s|${pkgs.pegasus-frontend}/bin/pegasus-fe|$out/bin/pegasus-fe|" \
        ${pkgs.pegasus-frontend}/share/applications/org.pegasus_frontend.Pegasus.desktop \
        > $out/share/applications/org.pegasus_frontend.Pegasus.desktop
    '';
  };

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
