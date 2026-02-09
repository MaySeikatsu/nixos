{
  config,
  pkgs,
  inputs,
  ...
}: let
  _base00 =
    builtins.trace "Stylix base00: ${config.lib.stylix.colors.base00}" null;
in {
  imports = [
    # Include the results of the hardware scan.
    inputs.home-manager.nixosModules.default
    ../modules/nixos/config/fonts.nix
    ../modules/nixos/config/services.nix
    ../modules/nixos/config/gnome.nix
    ../modules/nixos/config/gaming.nix
    ../modules/nixos/config/greeter.nix
    ../modules/nixos/config/localisation.nix
    ../modules/nixos/config/qt.nix
    ../modules/nixos/config/niri.nix
    ../modules/nixos/config/kanata.nix
    ../modules/nixos/config/stylix.nix
    ../modules/nixos/config/boot.nix
    ../modules/nixos/config/sddm-astronaut-theme.nix
    ../modules/nixos/pkgs/hyprland.nix
    ../modules/nixos/pkgs/terminal/essentials.nix
    ../modules/nixos/virtualisation.nix
    # ../modules/nixos/config/matugen.nix
    # ../modules/nixos/pkgs/terminal/rice.nix
    # ../modules/nixos/pkgs/audio_engineering.nix
    ../modules/home-manager/theming/spicetify.nix
  ];

  xdg.mime = {
    enable = true;
    addedAssociations = {
      "image/jpeg" = "feh-2.desktop";
      "image/png" = "feh-4.desktop;feh-3.desktop";
      "x-scheme-handler/http" = "zen-twilight.desktop;userapp-Zen-5GNJ22.desktop;userapp-Zen-KMVS52.desktop;floorp.desktop";
      "x-scheme-handler/https" = "zen-twilight.desktop;userapp-Zen-5GNJ22.desktop;userapp-Zen-KMVS52.desktop;floorp.desktop";
      "x-scheme-handler/chrome" = "zen-twilight.desktop;userapp-Zen-5GNJ22.desktop;userapp-Zen-KMVS52.desktop;floorp.desktop";
      "text/html" = "userapp-Zen-5GNJ22.desktop;userapp-Zen-KMVS52.desktop;zen-twilight.desktop;floorp.desktop";
      "application/x-extension-htm" = "userapp-Zen-5GNJ22.desktop;userapp-Zen-KMVS52.desktop;zen-twilight.desktop;floorp.desktop";
      "application/x-extension-html" = "userapp-Zen-5GNJ22.desktop;userapp-Zen-KMVS52.desktop;zen-twilight.desktop;floorp.desktop";
      "application/x-extension-shtml" = "userapp-Zen-5GNJ22.desktop;userapp-Zen-KMVS52.desktop;zen-twilight.desktop;floorp.desktop";
      "application/xhtml+xml" = "userapp-Zen-5GNJ22.desktop;userapp-Zen-KMVS52.desktop;zen-twilight.desktop;floorp.desktop";
      "application/x-extension-xhtml" = "userapp-Zen-5GNJ22.desktop;userapp-Zen-KMVS52.desktop;zen-twilight.desktop;floorp.desktop";
      "application/x-extension-xht" = "userapp-Zen-5GNJ22.desktop;userapp-Zen-KMVS52.desktop;zen-twilight.desktop;floorp.desktop";
    };
    defaultApplications = {
      "inode/directory" = "nautilus.desktop";
    };
    removedAssociations = {};
  };

  nix = {
    package = pkgs.lixPackageSets.stable.lix;
    settings.experimental-features = ["nix-command" "flakes"];
  };

  nixpkgs.config = {
    allowUnfree = true; # Allow unfree packages
    allowUnsupportedSystem = true; # Allow unsupported SystemPackages
  };

  # floorp.enable = true;
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

  # nix.settings.download-buffer-size = 524288000; # 500MB
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
    dates = ["03:45"];
  };
  # nix.settings.auto-optimise-store = true; # This would execute the optimisations on rebuild, does slow them down significantly though

  # Shared Programs should be defined here
  programs = {
    localsend.enable = true;
    nix-ld.enable = true;
    nix-ld.libraries = with pkgs; [
      imagemagick
      # add any libraries WallRizz needs here if needed
    ];

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
  # adjust to use a different kernel version
  boot.kernelPackages = pkgs.linuxPackages_latest; #turned off cause of issue with nvidia drivers

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
    # deskflow
    # lan-mouse
    remmina # rdp client
    waytrogen # rust based wallpaper changer
    mpv
    # matugen # rust
    # mochi
    # mise
    wallust # rust
    quickshell
    noctalia-shell
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
    inputs.fsel.packages.${pkgs.stdenv.hostPlatform.system}.default
    anki
    rose-pine-gtk-theme
    rose-pine-icon-theme
    spotify
    ledfx
    openlinkhub
    hyperion-ng # not working yet

    pomodoro
    swww
    mistral-vibe
    # hellwal
    # gtk3
    adw-gtk-theme #GTK Theming
    nwg-look
    qt6ct #QT Theming
    # gnome.adwaita-icon-theme

    krita
    godot_4
    blender
    libresprite
    aseprite
    goxel
    kicad # pcb and electronics design
    obsidian
    ticktick
    microsoft-edge
    # vivaldi
    # gimp
    gimp-with-plugins # broke on last update - reanable and troubleshoot
    # davinci-resolve
    poppler
    base16-schemes
    # darktable #like lightroom
    # tidal-hifi

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
    # spicetify-cli
    # pinentry
    gnupg
    cairo # 2d graphics library like opengl - fore issues with sherlock
    # gvfs # glib # same as above but no difference
    # feh
    evemu
    # linuxKernel.packages.linux_zen.digimend
    protonmail-desktop
    #teams
    teams-for-linux
    onlyoffice-desktopeditors
    omnisharp-roslyn
    tree-sitter
  ];

  # Increase system-wide file descriptor limit
  boot.kernel.sysctl = {"fs.file-max" = 524288;};

  # Increase limits for all users (including systemd services)
  # security.pam.loginLimits = [
  #   { domain = "*"; type = "soft"; item = "nofile"; value = "524288"; }
  #   { domain = "*"; type = "hard"; item = "nofile"; value = "524288"; }
  # ];

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
