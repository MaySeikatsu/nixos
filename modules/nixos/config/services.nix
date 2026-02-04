{
  config,
  pkgs,
  ...
}: {
  programs = {
    wayfire = {
      enable = false;
      # plugins = [
      #   pkgs.wcm
      # ];
    };
  };

  services = {
    # system76-scheduler = {
    #   enable =
    #     true; # without this the setting below would not apply - remove if battery life stays impacted negativly on BAT
    #   settings.cfsProfiles.enable =
    #     true; # enables custom system scheduler which should improve performance and battery life - automatically switches when on dc or bat
    # };
    power-profiles-daemon.enable = true;

    upower.enable =
      config.powerManagement.enable; # might not be needed its just for reporting to different desktop envs
    # Enable the KDE Plasma Desktop Environment.
    desktopManager = {
      plasma6.enable = false;
      cosmic.enable = false;
      gnome.enable = false;
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
    # tailscale.enable = true;
    # Tell the firewall to implicitly trust packets routed over Tailscale:
    # networking.firewall.trustedInterfaces = [ "tailscale0" ];

    udev.packages = with pkgs; [vial via]; # Enabling qmk vial

    #Enabled for end-4-dots flake:
    # geoclue2.enable = true;
    # networkmanager.enable = true;

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
