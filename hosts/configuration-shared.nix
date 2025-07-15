{ config, pkgs, inputs, lib, ... }:
let
  _base00 =
    builtins.trace "Stylix base00: ${config.lib.stylix.colors.base00}" null;
in {
  imports = [ # Include the results of the hardware scan.
    inputs.home-manager.nixosModules.default
    ./../modules/nixos/pkgs/terminal/essentials.nix
    ./../modules/nixos/pkgs/terminal/rice.nix
    ./../modules/nixos/pkgs/hyprland.nix
    ./../modules/home-manager/spicetify.nix
    ./../modules/nixos/config/kanata.nix
    ./../modules/nixos/config/matugen.nix
    ./../modules/nixos/config/stylix.nix
    ../modules/nixos/config/niri.nix
    ../modules/nixos/config/sddm-astronaut-theme.nix
    # ../modules/nixos/config/sddm-sugar-candy.nix
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config = {
    allowUnfree = true; # Allow unfree packages
    allowUnsupportedSystem = true; # Allow unsupported SystemPackages
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.maike = {
    isNormalUser = true;
    description = "maike";
    extraGroups = [
      "networkmanager"
      "wheel"
      "input" # for Kanata
      "uinput" # for Kanata
    ];
    shell = pkgs.zsh;
    packages = with pkgs;
      [
        kdePackages.kate
        # pipes
        #  thunderbird
      ];
  };

  # powerManagement.enable = true;
  powerManagement.powertop.enable = true;

  # also for quickshell (linting and ls)
  qt.enable = true;

  # nixCats = {
  #   enable = true;
  #   luaPath = "~/.config/nixCats-nvim/";
  #
  # };

  # xdg.portal = { # for discord and vesktop to fix startup issue (didn't help though) 
  #   enable = true;
  #   extraPortals = [ 
  #     pkgs.xdg-desktop-portal-hyprland 
  #     pkgs.xdg-desktop-portal-gtk 
  #   ];
  # };
  #
  #   xdg.portal = {
  #   enable = true;
  #   xdgOpenUsePortal = true;
  #   config = {
  #     common.default = [ "gtk" ];
  #     hyprland.default = [ "gtk" "hyprland" ];
  #     gnome.default = [ "gtk" "gnome" ];
  #     kde.default = [ "gtk" "kde" ];
  #   };
  #   extraPortals = [
  #     pkgs.xdg-desktop-portal-gtk
  #     pkgs.xdg-desktop-portal-hyprland
  #     pkgs.xdg-desktop-portal-gnome
  #     pkgs.kdePackages.xdg-desktop-portal-kde
  #   ];
  # };

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    roboto
    source-sans
    font-awesome
    openmoji-color
  ];

  security = {
    rtkit.enable = true;
    sudo.wheelNeedsPassword = false; # Request password for sudo actions as user

    # autoUpgrade.enable = true;
    # autoUpgrade.allowReboot = true; 
  };

  services = {
    system76-scheduler.enable =
      true; # without this the setting below would not apply - remove if battery life stays impacted negativly on BAT
    system76-scheduler.settings.cfsProfiles.enable =
      true; # enables custom system scheduler which should improve performance and battery life - automatically switches when on dc or bat
    upower.enable =
      config.powerManagement.enable; # might not be needed its just for reporting to different desktop envs
    # Enable the KDE Plasma Desktop Environment.
    # displayManager.sddm.enable = true; #now maaged by sddm-xxx file
    desktopManager.plasma6.enable = true;
    # displayManager.defaultSession = "hyprland"; #if not working write lower case  was a try to set hyprland as default option after logging in

    blueman.enable = true; # Enable Bluetooth (originally done for wacomtablet)
    printing.enable = true; # Enable CUPS to print documents.

    udev.packages = with pkgs; [ vial via ]; # Enabling qmk vial

    # Enable sound with pipewire.
    pulseaudio.enable = false;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;
    };

    displayManager.gdm.enable = false;
    desktopManager.gnome.enable = true;
    xserver = {
      # Enable the GNOME Desktop Environment.
      desktopManager.kodi.enable = true;
      # desktopManager.plasma5.bigscreen.enable = true;

      wacom.enable = true; # Enable Wacom Tablet

      # Configure keymap in X11
      xkb = {
        layout = "us";
        variant = "altgr-intl";
      };
    };

    # Enable VR with Monado / OpenXR and SteamVR
    # monado = {
    #   enable = true;
    #   defaultRuntime = true; # Register as default OpenXR runtime
    # };
  };

  # Shared Programs should be defined here
  programs = {
    # Nixos Helper for cleanup and commands
    nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 14d --keep 12";
      flake =
        "/home/maike/.config/nixos"; # might need adjustment to different hosts
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
      enable = true;
      # plugins = [
      #   pkgs.wcm
      # ];
    };

    gamemode.enable =
      true; # Enabling optional optimisations for gaming / game-mode
    # floorp.enable = true;     # Enable/Install Floorp

    # Steam
    steam = {
      enable = true;
      extraCompatPackages = [
        # Setting up directory in which protonup should store its' proton-ge versions - run 'protonup' command in console afterwards to initialize 
        # Install proton-ge
        # could also be done via home-manager - view vimjoyer gaming video
        pkgs.proton-ge-bin
      ];
      gamescopeSession =
        { # allows to boot directly into the steamdeck / big picture mode
          enable = true;
        };
    };
    # Enable git-lfs to use hand trackers in VR

    # mtr.enable = true;
    gnupg.agent = { # for gpg keys i think, could be deleted as it did not work
      enable = true;
      enableSSHSupport = true;
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

  environment.systemPackages =
    with pkgs; [ # would be pkgs.packagename without the with pkgs;
      neovim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
      git
      # warp-terminal
      wget
      # kanata
      gcc
      tealdeer
      rustup
      rustfmt
      rust-analyzer
      deskflow
      lan-mouse
      remmina # rdp client
      ncdu # storage scanning and cleanup tool
      # waypaper
      waytrogen # rust based wallpaper changer
      matugen
      inputs.matugen.packages.${system}.default
      pywal
      wallust
      power-profiles-daemon
      powertop
      # hyprpanel #imported flawith the repo which can be used with Home Manager.
      # Exampleke
      # inputs.hyprddm.packages.${pkgs.system}.default

      floorp
      # catppuccin-grub

      protonup
      protonup-rs
      protonup-qt
      protonplus
      lutris
      heroic
      bottles
      mangohud
      steam-tui
      steamcmd
      ntfs3g # to run steam games on ntfs drives with linux - drive needs to be mounted with ntfs-3g too, to make it work
      ledfx
      # For Steam VR (troubleshooting):
      # procps
      # usbutils
      lshw # to show hardware info(needed for nvidia config)
      inputs.nvix.packages.${pkgs.system}.full
      inputs.quickshell.packages.${system}.default
      inputs.ashell.defaultPackage.${pkgs.system}
      # inputs.eww.packages.${system}.default #should work both
      inputs.eww.packages.${system}.default # eww-wayland
      inputs.ironbar.packages.${system}.default
      # ironbar
      polybar
      ripgrep
      spotify
      # discord #managed via nixcord flake 
      # vesktop #vencord desktop client without overwriting the official discord binary
      revolt-desktop
      element-desktop
      osu-lazer-bin
      easyeffects
      zed-editor
      code-cursor
      hellwal
      # microsoft-edge
      obsidian
      ticktick
      gimp-with-plugins
      krita
      godot_4
      blender
      libresprite
      aseprite
      goxel
      # inputs.zen-browser.packages."${system}".twilight #is now seperate in zen-browser.nix
      kicad # pcb and electronics design
      obs-studio
      # davinci-resolve
      poppler
      base16-schemes
      darktable
      tidal-hifi
      jq
      # For quickshell config
      kdePackages.qtsvg
      libsForQt5.qt5.qtsvg
      libsForQt5.qt5.qtimageformats
      libsForQt5.qt5.qtmultimedia
      kdePackages.qtmultimedia
      kdePackages.qt5compat
      qt5.qtdeclarative

      libsForQt5.qt5.qtgraphicaleffects
      kdePackages.syntax-highlighting
      material-symbols

      kodi-wayland
      libsForQt5.plasma-bigscreen

      #neovim npm
      nodejs_20
      nodePackages.npm

      ollama
      # lmstudio
      docker
      ffmpeg
      p7zip
      overskride
      bluez
      bluez-tools
      pavucontrol # audio volume and device control
      # firefoxpwa
      vial
      via
      intiface-central
      protontricks

      localsend
      # spicetify-cli
      qtpass
      # pinentry
      gnupg

      # feh
      vital
      # opentabletdriver #not working yet
      # wacomtablet
      evemu
      # linuxKernel.packages.linux_zen.digimend
      # roccat-tools

      #teams
      teams-for-linux
      onlyoffice-bin
      google-cloud-sdk
      terraform
      # citrix_workspace
      vscode
      # dotnet-sdk_8
      omnisharp-roslyn
      unzip
      dotnetCorePackages.sdk_8_0_1xx
    ];

  # Increase system-wide file descriptor limit
  boot.kernel.sysctl = { "fs.file-max" = 524288; };

  # Increase limits for all users (including systemd services)
  # security.pam.loginLimits = [
  #   { domain = "*"; type = "soft"; item = "nofile"; value = "524288"; }
  #   { domain = "*"; type = "hard"; item = "nofile"; value = "524288"; }
  # ];

  # Specifically for the nix-daemon (if relevant)
  systemd.services.nix-daemon.serviceConfig.LimitNOFILE = 1048576;

}
