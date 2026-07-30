{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: let
  _base00 =
    builtins.trace "Stylix base00: ${config.lib.stylix.colors.base00}" null;
in {
  imports = [
    # Include the results of the hardware scan.
    inputs.home-manager.nixosModules.default
    ../modules/nixos/config
    ../modules/nixos/pkgs/terminal/essentials.nix
    ../modules/nixos/virtualisation.nix
    ../modules/home-manager/theming/spicetify.nix
    # ../modules/nixos/pkgs/hyprland.nix
    # ../modules/nixos/pkgs/terminal/rice.nix
    # ../modules/nixos/pkgs/audio_engineering.nix
  ];

  systemd.services."virt-secret-init-encryption".enable = false; # fix for bug, remove at next flake release

  # system.nixos-init.enable = true;
  # services.journald.extraConfig = "SystemMaxUse=1G";

  programs.fish.enable = true;

  users.defaultUserShell = pkgs.fish;
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.maike = {
    isNormalUser = true;
    description = "maike";
    extraGroups = [
      "networkmanager"
      "wheel"
      "input" # for Kanata
      "uinput" # for Kanata
      "docker"
    ];
    useDefaultShell = false;
    shell = pkgs.fish; # shell = pkgs.zsh;     # shell = pkgs.nushell;
    packages = with pkgs; [
      kdePackages.kate
      #  thunderbird
    ];
  };

  #Crosscompile aarch64 on x86_64-linux for remote compiling on pi
  boot.binfmt.emulatedSystems = ["aarch64-linux"];
  nix.settings.extra-platforms = ["aarch64-linux"];
  # nix.config.trusted-users = [
  #   "root"
  #   "maike"
  # ];

  # powerManagement.enable = true;
  powerManagement.powertop.enable = true;

  # nixCats = {
  #   enable = true;
  #   luaPath = "~/.config/nixCats-nvim/";
  #
  # };

  security.pam.services.wayvnc = {};

  security = {
    rtkit.enable = true;
    sudo.wheelNeedsPassword = true; # Request password for sudo actions as user
    # autoUpgrade.enable = true;
    # autoUpgrade.allowReboot = true;
  };

  # Shared Programs should be defined here
  programs = {
    localsend.enable = true;
    nix-ld.enable = true;
    nix-ld.libraries = with pkgs; [
      imagemagick
      # add any libraries WallRizz needs here if needed
    ];

    direnv = {
      enable = true;
      # silent = true;
      # loadInNixShell = false;
      nix-direnv.enable = true;
      enableFishIntegration = true;
      # settings = {};
    };

    # zsh.enable = true; # Enable ZSH
    # zsh.enableCompletion = false;
    # # zsh.enableGlobalCompInit = false;

    kdeconnect.enable = true;

    # mtr.enable = true;
    gnupg.agent = {
      # for gpg keys i think, could be deleted as it did not work
      enable = true;
      # enableSSHSupport = true;
      pinentryPackage = pkgs.pinentry-curses;
    };
  };

  # Shared hardware configuration should be defined here
  hardware = {
    bluetooth.enable = true;
    # pulseaudio.enable = false;
  };

  environment = {
    sessionVariables = {
      NIXOS_OZONE_WL = 1;
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "~/.steam/root/compatibilitytools.d/";

      ##davinci-resolve on wayland / niri
      #ROC_ENABLE_PRE_VEGA=1;
      #RUSTICL_ENABLE="amdgpu,amdgpu-pro,radv,radeon,radeonsi";
      #DRI_PRIME=1;
      #QT_QPA_PLATFORM="xcb";
      #
      ## LD_PRELOAD="/usr/lib/libgio-2.0.so /usr/lib/libgmodule-2.0.so /usr/lib/libglib-2.0.so";
    };

    variables = {
      EDITOR = "nvim";
      SUDO_EDITOR = "nvim";

      terminal = "ghostty";
      browser = "zen-twilight";
    };
  };

  # adjust to use a different kernel version
  # boot.kernelPackages = pkgs.linuxPackages; #turned off cause of issue with nvidia drivers

  # Enable Bluetooth Driver for Multiple Tablets
  # services.xserver.digimend.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # programs.uwsm.enable = true;
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    xdgOpenUsePortal = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-wlr
      pkgs.xdg-desktop-portal-gtk
      # pkgs.xdg-desktop-portal-gnome
      # pkgs.xdg-desktop-portal-hyprland
      # pkgs.xdg-desktop-portal-kde
      pkgs.gnome-keyring
    ];
    configPackages = [
      pkgs.xdg-desktop-portal-wlr
      pkgs.xdg-desktop-portal-gtk
    ];
    config = {
      niri = {
        default = lib.mkForce ["gtk"];
        "org.freedesktop.impl.portal.ScreenCast" = ["wlr"];
        "org.freedesktop.impl.portal.Screenshot" = ["wlr"];
        "org.freedesktop.impl.portal.Secret" = ["gnome-keyring"];
      };
      default = {
        default = ["gtk"];
        "org.freedesktop.impl.portal.ScreenCast" = ["wlr"];
        "org.freedesktop.impl.portal.Screenshot" = ["wlr"];
        "org.freedesktop.impl.portal.Secret" = ["gnome-keyring"];
      };
    };
  };

  environment.systemPackages = with pkgs; [
    tailscale
    proton-vpn
    proton-vpn-cli
    # deskflow
    # lan-mouse
    remmina # rdp client
    waytrogen # rust based wallpaper changer
    mpv
    yt-dlp
    matugen # rust
    mpvpaper # for shell / video wallpaper
    socat # for shell / mpvpaper timecode steering
    wl-gammarelay-rs # for shell / lut like color filtering
    libsForQt5.qt5ct
    # mochi
    # mise
    wallust # rust
    quickshell
    noctalia-shell
    # inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
    openssl
    pkg-config
    # dms-shell # dank-material-shell
    inputs.system76-scheduler-niri.packages.${pkgs.stdenv.hostPlatform.system}.default
    # inputs.qs-caelestia-shell.packages.${pkgs.stdenv.hostPlatform.system}.default
    # inputs.qs-caelestia-cli.packages.${pkgs.stdenv.hostPlatform.system}.default
    # inputs.mistral-vibe.packages.${pkgs.stdenv.hostPlatform.system}.default
    # inputs.nuls.packages.${stdenv.hostPlatform.system}.default
    # inputs.matugen.packages.${pkgs.stdenv.hostPlatform.system}.default
    # inputs.qs-noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
    # inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default
    # inputs.ironbar.packages.${pkgs.stdenv.hostPlatform.system}.default
    # inputs.nvix.packages.${pkgs.stdenv.hostPlatform.system}.full
    # inputs.qs-retroism.packages.${pkgs.stdenv.hostPlatform.system}.default
    # inputs.winboat.packages.${pkgs.stdenv.hostPlatform.system}.winboat
    # inputs.winapps.packages.${pkgs.stdenv.hostPlatform.system}.winapps
    # inputs.winapps.packages.${pkgs.stdenv.hostPlatform.system}.winapps-launcher
    # inputs.millennium.packages.${pkgs.stdenv.hostPlatform.system}.millennium
    # inputs.rproc.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.fsel.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.spotatui.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.iris.packages.${pkgs.stdenv.hostPlatform.system}.default
    # winboat
    rapidraw
    anki
    rose-pine-gtk-theme
    rose-pine-icon-theme
    exiftool # Metadata readout for images and different files formats
    spotify
    # ledfx
    openlinkhub
    hyperion-ng # not working yet
    pomodoro
    awww
    # hellwal
    # gtk3
    adw-gtk3
    matcha-gtk-theme #GTK Theming
    nwg-look # GTK Themeset
    kdePackages.qt6ct #QT Theming
    # gnome.adwaita-icon-theme
    # nvtopPackages.full

    # voicevox
    krita
    blender
    libresprite
    aseprite
    goxel
    kicad # pcb and electronics design
    obsidian
    ticktick
    # gimp
    gimp-with-plugins
    poppler
    davinci-resolve
    # kdePackages.kdenlive
    base16-schemes
    darktable #like lightroom
    rawtherapee

    # For Dolphin without KDE Plasma
    kdePackages.dolphin
    kdePackages.qtsvg
    kdePackages.kio
    kdePackages.kio-fuse
    kdePackages.kio-extras
    kdePackages.plasma-workspace # to fix issue with mime associations in dolphin
    gnome-disk-utility
    nautilus
    material-symbols
    cosmic-files
    superfile

    freerdp
    iptables
    ffmpeg
    p7zip
    overskride
    bluez
    bluez-tools
    vial
    # via
    intiface-central
    protontricks
    # spicetify-cli
    # pinentry
    gnupg
    cairo # 2d graphics library like opengl - fore issues with sherlock
    # gvfs # glib # same as above but no difference
    # feh
    evemu
    cliamp
    # linuxKernel.packages.linux_zen.digimend
    protonmail-desktop
    #teams
    teams-for-linux
    onlyoffice-desktopeditors
    omnisharp-roslyn
  ];

  environment.etc."/xdg/menus/applications.menu".text =
    builtins.readFile
    "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu"; # Specifically for the nix-daemon (if relevant) // this actually fixed the dolphine mime app issue

  systemd.services.flatpak-repo = {
    wantedBy = ["multi-user.target"];
    path = [pkgs.flatpak];
    script = ''
      flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    '';
  };

  # specialisation = {
  #   retro.configuration = {
  #     system.nixos.tags = ["retro"];
  #     services = {
  #       displayManager.sddm.enable = false;
  #       sysc-greet = {
  #         enable = false;
  #         compositor = "niri"; # or "hyprland" or "sway"
  #         settings = {
  #           theme = "TransIsHardJob";
  #         };
  #         # settings.initial_session = {
  #         #   command = "niri";
  #         #   user = "maike";
  #         # };
  #       };
  #     };
  #   };
  # };
}
