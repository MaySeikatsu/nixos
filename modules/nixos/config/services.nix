{
  config,
  pkgs,
  ...
}: {
  services = {
    system76-scheduler = {
      enable =
        true; # without this the setting below would not apply - remove if battery life stays impacted negativly on BAT
      settings.cfsProfiles.enable =
        true; # enables custom system scheduler which should improve performance and battery life - automatically switches when on dc or bat
      # settings.processScheduler.pipewireBoost.enable = true;
    };
    power-profiles-daemon.enable = true;
    upower.enable =
      config.powerManagement.enable; # might not be needed its just for reporting to different desktop envs

    # Added as config for USWM (comes with hyprland-uwsm but not in HM)
    dbus.implementation = "broker";
    # Enable the KDE Plasma Desktop Environment.
    desktopManager = {
      plasma6.enable = true;
      cosmic.enable = false;
      gnome.enable = true;
    };

    displayManager = {
      # sddm.enable = true; #now maaged by sddm-xxx file
      sddm.wayland.enable = true;
      gdm.enable = false;
      defaultSession = "niri"; # "hyprland-uwsm"; # default option after logging in
      autoLogin.enable = false;
      autoLogin.user = "maike";
    };

    blueman.enable = true; # Enable Bluetooth (originally done for wacomtablet)
    printing.enable = true; # Enable CUPS to print documents.
    flatpak.enable = true;

    udev.packages = with pkgs; [vial via]; # Enabling qmk vial

    #Enabled for end-4-dots flake:
    # geoclue2.enable = true;
    # networkmanager.enable = true;

    xserver = {
      # enable = true;
      # Enable the GNOME Desktop Environment.
      # desktopManager.plasma5.bigscreen.enable = true;

      # wacom.enable = true; # Enable Wacom Tablet

      # Configure keymap in X11
      xkb = {
        layout = "us, de";
        variant = "altgr-intl, ";
      };
    };

    hardware.openrgb = {
      enable = true;
      # startupProfile = "";
    };

    # Enable VR with Monado / OpenXR and SteamVR
    # monado = {
    #   enable = true;
    #   defaultRuntime = true; # Register as default OpenXR runtime
    # };
  };
}
