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

    # kwin_wayland's atomic DRM commit path repeatedly fails against the
    # NVIDIA proprietary driver here (GTX 1060, driver 580.x) -
    # "kwin_wayland_drm: Atomic modeset commit failed! Invalid argument"
    # spams the journal on every boot, and is why Plasma / Plasma Bigscreen
    # sessions fail to come up while niri/mango (not kwin-based) work fine.
    # KWIN_DRM_NO_AMS forces kwin back to the legacy (non-atomic) DRM API.
    # Scoped to the kwin_wayland unit only, so niri is unaffected. Plasma
    # Bigscreen goes through the same plasma-workspace session machinery
    # (plasma-dbus-run-session-if-needed), so it picks this up too.

    displayManager = {
      # sddm.enable = true; #now maaged by sddm-xxx file
      sddm.wayland.enable = true;
      gdm.enable = false;
      defaultSession = "niri"; # "hyprland-uwsm"; # default option after logging in
      autoLogin.enable = false;
      autoLogin.user = "maike";
      sessionPackages = [pkgs.kdePackages.plasma-bigscreen];
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
  };

  # See comment above desktopManager.plasma6 - works around kwin_wayland
  # atomic DRM commit failures on the NVIDIA proprietary driver.
  systemd.user.services."plasma-kwin_wayland".environment.KWIN_DRM_NO_AMS = "1";
}
