{ config, pkgs, inputs, lib, ... }:
# let
#   wallpaper = "~/.config/nixos/ressources/wallpapers/1359465.png";
# in  
{
  imports =
    [ # Include the results of the hardware scan.
      inputs.home-manager.nixosModules.default 
      ./../modules/nixos/pkgs/terminal/essentials.nix
      ./../modules/nixos/pkgs/terminal/rice.nix
      ./../modules/nixos/pkgs/hyprland.nix
      # ./../modules/home-manager/spicetify.nix
      ./../modules/nixos/config/kanata.nix
      ./../modules/nixos/config/matugen.nix
      ./../modules/nixos/config/stylix.nix
      # ./sddm-theme.nix
      # ./../../modules/system/displaymanager.nix
    ];

  nix.settings.experimental-features = ["nix-command" "flakes"];
  nixpkgs.config = {
      allowUnfree = true;               # Allow unfree packages
      allowUnsupportedSystem = true;    # Allow unsupported SystemPackages
    };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.maike = {
    isNormalUser = true;
    description = "maike";
    extraGroups = [ 
    "networkmanager"
    "wheel" 
    "input" #for Kanata
    "uinput" #for Kanata
    ];
    shell = pkgs.zsh;
    packages = with pkgs; [
      kdePackages.kate
      # pipes
    #  thunderbird
    ];
  };

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
    sudo.wheelNeedsPassword = true;   #Request password for sudo actions as user

    # autoUpgrade.enable = true;
    # autoUpgrade.allowReboot = true; 
  };

  services = {
    # Enable the KDE Plasma Desktop Environment.
    displayManager.sddm.enable = true;
    desktopManager.plasma6.enable = true;
    # displayManager.defaultSession = "hyprland"; #if not working write lower case  was a try to set hyprland as default option after logging in

    blueman.enable = true;                       # Enable Bluetooth (originally done for wacomtablet)
    printing.enable = true;             # Enable CUPS to print documents.

    udev.packages = with pkgs; [ vial via ];     # Enabling qmk vial 

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

    xserver = {
      # Enable the GNOME Desktop Environment.
      displayManager.gdm.enable = false;
      desktopManager.gnome.enable = true;

      wacom.enable = true;         # Enable Wacom Tablet

      # Configure keymap in X11
      xkb = {
        layout = "us";
        variant = "altgr-intl";
      };
    };

    # Enable VR with Monado / OpenXR and SteamVR
    monado = {
      enable = true;
      defaultRuntime = true; # Register as default OpenXR runtime
    };
  };

  # Shared Programs should be defined here
  programs = {
    # Nixos Helper for cleanup and commands
    nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 14d --keep 12";
      flake = "/home/maike/.config/nixos"; # might need adjustment to different hosts
    };

    # Enable Hyprland
    hyprland.enable = true;
    hyprland.withUWSM = true;

    zsh.enable = true;    # Enable ZSH
    firefox.enable = true;     # Install firefox.
    kdeconnect.enable = true;

    wayfire = {
      enable = true;  
      # plugins = [
      #   pkgs.wcm
      # ];
    };

    gamemode.enable = true;     # Enabling optional optimisations for gaming / game-mode
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
      gamescopeSession = { # allows to boot directly into the steamdeck / big picture mode
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

    steam-hardware = {   # Troubleshooting for steamvr not detecting hardware
      enable = true;
    };

    # Enable opentabletdriver
    # opentabletdriver.enable = true;
    # opentabletdriver.daemon.enable = true;
  };


  environment = {
    sessionVariables = {
    NIXOS_OZONE_WL = "1";
      STEAM_EXTRA_COMPAT_TOOLS_PATHS =
        "~/.steam/root/compatibilitytools.d/";
    };

    variables = {
      EDITOR = "nvim";
      SUDO_EDITOR = "nvim";
  
  terminal = "ghostty";
  browser = "zen-twilight";
    };
  };

  networking.networkmanager.enable = true;   # Enable networking
  #boot.kernelPackages = pkgs.linuxPackages_latest; #turned off cause of issue with nvidia drivers
  
  # Enable Bluetooth Driver for Multiple Tablets
  # services.xserver.digimend.enable = true;


  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  
  # Enable VR with Monado / OpenXR and SteamVR
  systemd.user.services.monado.environment = {
    STEAMVR_LH_ENABLE = "1";
    XRT_COMPOSITOR_COMPUTE = "1";
  };

  environment.systemPackages = with pkgs; [ #would be pkgs.packagename without the with pkgs;
    neovim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    alacritty
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
    remmina #rdp client
    ncdu    #storage scanning and cleanup tool
    # waypaper
    waytrogen #rust based wallpaper changer
    matugen
    inputs.matugen.packages.${system}.default
    pywal
    power-profiles-daemon
    # hyprpanel #imported flake
    # inputs.hyprddm.packages.${pkgs.system}.default

    floorp
    # catppuccin-grub

    protonup
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
    lshw #to show hardware info(needed for nvidia config)

    spotify
    # discord #managed via nixcord flake 
    # vesktop #vencord desktop client without overwriting the official discord binary
    revolt-desktop
    element-desktop
    osu-lazer-bin
    microsoft-edge
    obsidian ticktick gimp-with-plugins
    krita
    godot_4
    blender
    libresprite
    aseprite
    # inputs.zen-browser.packages."${system}".twilight #is now seperate in zen-browser.nix
    goxel
    # kicad #pcb and electronics design
    obs-studio
    davinci-resolve
    poppler
    base16-schemes
    darktable

    ollama
    # lmstudio
    docker
    ffmpeg
    p7zip
    overskride 
    bluez
    bluez-tools
    pavucontrol #audio volume and device control
    # firefoxpwa
    vial
    via

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
    # steam
    onlyoffice-bin
    google-cloud-sdk
    terraform
    # citrix_workspace
    vscode



    # Install kde packages for sddm to work first three are dependencies - currently unused
    kdePackages.qtsvg
    kdePackages.qtvirtualkeyboard
    kdePackages.qtmultimedia
    # (pkgs.callPackage ../../pkgs/sddm-astronaut-theme.nix {
    #   theme = "hyprland_kath";
    #   themeConfig={
    #    General = {
    #      HeaderText ="Hi";
    #       Background="/home/user/Desktop/wp.png";
    #       FontSize="10.0";
    #    };	
    #  };
    # })
  ];

}
