{
  config,
  pkgs,
  inputs,
  system,
  lib,
  ...
}:
let
  _base00 = builtins.trace "Stylix base00: ${config.lib.stylix.colors.base00}" null;
in
{
  imports = [
    # Include the results of the hardware scan.
    inputs.home-manager.nixosModules.default
    ../modules/nixos/config/fonts.nix
    ../modules/nixos/config/services.nix
    ../modules/nixos/config/gnome.nix
    ../modules/nixos/config/localisation.nix
    ../modules/nixos/config/qt.nix
    ../modules/nixos/config/niri.nix
    ../modules/nixos/config/kanata.nix
    ../modules/nixos/config/stylix.nix
    ../modules/nixos/config/matugen.nix
    ../modules/nixos/config/sddm-astronaut-theme.nix
    ../modules/nixos/pkgs/hyprland.nix
    ../modules/nixos/pkgs/terminal/rice.nix
    ../modules/nixos/pkgs/terminal/essentials.nix
    ../modules/nixos/virtualisation.nix
    # ../modules/nixos/pkgs/audio_engineering.nix
    ../modules/home-manager/theming/spicetify.nix
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nixpkgs.config = {
    allowUnfree = true; # Allow unfree packages
    allowUnsupportedSystem = true; # Allow unsupported SystemPackages
  };

  # system.nixos-init.enable = true;
  # services.journald.extraConfig = "SystemMaxUse=1G";

  users.defaultUserShell = pkgs.nushell;
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
    shell = pkgs.nushell; # shell = pkgs.zsh;     # shell = pkgs.fish;
    packages = with pkgs; [
      kdePackages.kate
      #  thunderbird
    ];
  };
  #Crosscompile aarch64 on x86_64-linux for remote compiling on pi
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  nix.settings.extra-platforms = [ "aarch64-linux" ];
  # nix.config.trusted-users = [
  #   "root"
  #   "maike"
  # ];

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    imagemagick
    # add any libraries WallRizz needs here if needed
  ];

  # powerManagement.enable = true;
  powerManagement.powertop.enable = true;

  # nixCats = {
  #   enable = true;
  #   luaPath = "~/.config/nixCats-nvim/";
  #
  # };

  nix.settings.download-buffer-size = 524288000; # 500MB
  systemd.services.nix-daemon.serviceConfig.LimitNOFILE = 1048576;

  security = {
    rtkit.enable = true;
    sudo.wheelNeedsPassword = false; # Request password for sudo actions as user

    # autoUpgrade.enable = true;
    # autoUpgrade.allowReboot = true;
  };

  # nix.gc = {
  #   automatic = true;
  #   dates = "weekly";
  #   options = "--delete-older-than 15d";
  # };

  # Storage Optimisations between different nix stores:
  nix.optimise = {
    automatic = true;
    dates = [ "03:45" ];
  };
  # nix.settings.auto-optimise-store = true; # This would execute the optimisations on rebuild, does slow them down significantly though

  # Shared Programs should be defined here
  programs = {
    # Nixos Helper for cleanup and commands
    nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 14d --keep 7";
      flake = "/home/maike/.config/nixos"; # might need adjustment to different hosts
    };
    direnv = {
      enable = true;
      # silent = true;
      # loadInNixShell = false;
      # nix-direenv.enable = true;
      # enableFishIntegration = true;
      # settings = {};
    };

    # Enable Hyprland
    hyprland.enable = true;
    hyprland.withUWSM = true;

    zsh.enable = true; # Enable ZSH
    zsh.enableCompletion = false;
    # zsh.enableGlobalCompInit = false;

    firefox.enable = true; # Install firefox.
    kdeconnect.enable = true;

    wayfire = {
      enable = false;
      # plugins = [
      #   pkgs.wcm
      # ];
    };

    # xwayland needed for x11 / xserver support on niri for steam
    xwayland.enable = true;
    gamemode.enable = true; # Enabling optional optimisations for gaming / game-mode
    # floorp.enable = true;     # Enable/Install Floorp

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
    # Enable git-lfs to use hand trackers in VR

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

    # steam-hardware = {   # Troubleshooting for steamvr not detecting hardware
    #   enable = true;
    # };

    # Enable opentabletdriver
    # opentabletdriver.enable = true;
    # opentabletdriver.daemon.enable = true;
  };

  environment = {
    sessionVariables = {
      NIXOS_OZONE_WL = 1;
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "~/.steam/root/compatibilitytools.d/";
    };

    variables = {
      EDITOR = "nvim";
      SUDO_EDITOR = "nvim";

      terminal = "ghostty";
      browser = "zen-twilight";
    };
  };

  networking.networkmanager.enable = true; # Enable networking
  networking.firewall.enable = true;
  #boot.kernelPackages = pkgs.linuxPackages_latest; #turned off cause of issue with nvidia drivers

  # Enable Bluetooth Driver for Multiple Tablets
  # services.xserver.digimend.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Enable VR with Monado / OpenXR and SteamVR
  # systemd.user.services.monado.environment = {
  #   STEAMVR_LH_ENABLE = "1";
  #   XRT_COMPOSITOR_COMPUTE = "1";
  # };

  environment.systemPackages = with pkgs; [
    neovim
    git
    wget
    kanata
    gh
    # deskflow
    # lan-mouse
    remmina # rdp client
    waytrogen # rust based wallpaper changer
    matugen # rust
    inputs.matugen.packages.${pkgs.stdenv.hostPlatform.system}.default
    wallust # rust
    power-profiles-daemon
    # floorp-bin
    wineWowPackages.stable
    wineWowPackages.waylandFull
    winetricks
    protontricks
    protonup-ng
    protonup-rs
    protonup-qt
    protonplus
    lutris
    heroic
    bottles
    mangohud
    steamcmd
    ntfs3g # to run steam games on ntfs drives with linux - drive needs to be mounted with ntfs-3g too, to make it work
    inputs.nvix.packages.${pkgs.stdenv.hostPlatform.system}.full
    inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default
    # inputs.ironbar.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.qs-noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.qs-caelestia-shell.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.qs-caelestia-cli.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.mistral-vibe.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.nuls.packages.${system}.default
    # inputs.qs-retroism.packages.${pkgs.stdenv.hostPlatform.system}.default
    # inputs.winboat.packages.${pkgs.stdenv.hostPlatform.system}.winboat
    # inputs.winapps.packages.${pkgs.stdenv.hostPlatform.system}.winapps
    # inputs.winapps.packages.${pkgs.stdenv.hostPlatform.system}.winapps-launcher
    # inputs.millennium.packages.${pkgs.stdenv.hostPlatform.system}.millennium
    rose-pine-gtk-theme
    rose-pine-icon-theme
    spotify
    # spicetify-cli
    ledfx
    openrgb-with-all-plugins
    openlinkhub
    hyperion-ng # not working yet
    # gtk3
    # gnome.adwaita-icon-theme
    vesktop # vencord desktop client without overwriting the official discord binary
    element-desktop
    signal-desktop
    beeper
    beeper-bridge-manager
    fluffychat
    osu-lazer-bin
    prismlauncher
    easyeffects
    tenacity
    # zed-editor
    # code-cursor
    helix
    vscode
    pomodoro
    # hellwal
    microsoft-edge
    vivaldi
    obsidian
    ticktick
    # gimp-with-plugins #broke on last update - reanable and troubleshoot
    gimp
    krita
    godot_4
    blender
    libresprite
    aseprite
    goxel
    # inputs.zen-browser.packages."${pkgs.stdenv.hostPlatform.system}".twilight #is now seperate in zen-browser.nix
    kicad # pcb and electronics design
    obs-studio
    # davinci-resolve
    poppler
    base16-schemes
    # darktable #like lightroom
    # tidal-hifi
    # For quickshell caelestia config (should be able to be deleted)
    kdePackages.qtsvg
    libsForQt5.qt5.qtsvg
    libsForQt5.qt5.qtimageformats
    libsForQt5.qt5.qtmultimedia
    kdePackages.qtmultimedia
    kdePackages.qt5compat
    kdePackages.okular
    qt5.qtdeclarative
    libsForQt5.qt5.qtgraphicaleffects
    kdePackages.syntax-highlighting
    kdePackages.plasma-workspace # to fix issue with mime associations in dolphin
    material-symbols
    kodi-wayland
    # libsForQt5.plasma-bigscreen
    ollama
    # lmstudio

    freerdp
    iptables
    ffmpeg
    p7zip
    overskride
    bluez
    bluez-tools
    pavucontrol # audio volume and device control
    # firefoxpwa
    vial
    # via
    intiface-central
    protontricks
    localsend
    # spicetify-cli
    qtpass
    # pinentry
    gnupg
    cairo # 2d graphics library like opengl - fore issues with sherlock
    # gvfs # glib # same as above but no difference
    # feh
    # opentabletdriver #not working yet
    # wacomtablet
    evemu
    # linuxKernel.packages.linux_zen.digimend
    # roccat-tools
    protonmail-desktop
    proton-pass
    #teams
    teams-for-linux
    onlyoffice-desktopeditors
    # citrix_workspace
    # dotnet-sdk_8
    omnisharp-roslyn
  ];

  # Increase system-wide file descriptor limit
  boot.kernel.sysctl = {
    "fs.file-max" = 524288;
  };

  # Increase limits for all users (including systemd services)
  # security.pam.loginLimits = [
  #   { domain = "*"; type = "soft"; item = "nofile"; value = "524288"; }
  #   { domain = "*"; type = "hard"; item = "nofile"; value = "524288"; }
  # ];

  environment.etc."/xdg/menus/applications.menu".text =
    builtins.readFile "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu"; # Specifically for the nix-daemon (if relevant) // this actually fixed the dolphine mime app issue

  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo  
    '';
  };
}
