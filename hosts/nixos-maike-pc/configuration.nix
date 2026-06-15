# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./../configuration-shared.nix
    ./hardware-configuration.nix
  ];

  # Bootloader.
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    # loader.systemd-boot.configurationLimit = 5;
    # Load nvidia modules early so niri/Wayland can initialize the display
    # initrd.kernelModules = ["nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm"];
    # Required for newer nvidia drivers (545+) to expose a KMS framebuffer for Wayland
    kernelParams = ["nvidia_drm.fbdev=1"];
    # Tell the kernel where to look for a hibernation image so that
    # `systemctl hibernate` can actually resume on the next boot.
    # Same UUID as the swap partition in hardware-configuration.nix.
    # Verify after rebuild with:  cat /proc/cmdline | grep -o 'resume=[^ ]*'
    resumeDevice = "/dev/disk/by-uuid/b2fa32a1-4cc9-485e-a55f-ce0b954bd2e2";
    # loader.grub = {
    #   enable = true;
    #   efiSupport = true;
    # };
  };
  boot.kernelPackages = pkgs.linuxPackages;

  # Enable suspend & hibernate, and use the "shutdown" hibernation mode.
  # Why "shutdown"? The default ("platform") asks ACPI to enter S4 after
  # writing the image, which on this nvidia desktop frequently hangs (same
  # nvidia_drm Flip-event-timeout we see at poweroff). "shutdown" simply
  # writes the image and powers off cleanly via the regular shutdown path,
  # then the next boot detects the image and resumes (needs boot.resumeDevice,
  # set above).
  systemd.sleep.settings.Sleep = {
    AllowSuspend = true;
    AllowHibernation = true;
    AllowSuspendThenHibernate = true;
    AllowHybridSleep = true;
    HibernateMode = "shutdown";
    # allowExternalGpu = true;
  };

  # Don't let a misbehaving unit hold the whole shutdown hostage for the
  # systemd default of 90s. With nvidia-drm flip-event timeouts during
  # shutdown/suspend, units can easily stall - cap them to 30s so that
  # `systemctl poweroff` always completes in a bounded time.
  # Affects both regular stop (SIGTERM grace) and the abort (SIGABRT grace)
  # branches. Long-running stops we care about (docker, libvirtd) still
  # finish well within 30s when there's nothing actively running in them.
  # Note: only affects the SYSTEM manager. User units keep the default;
  # add `systemd.user.extraConfig` here as well if you want the same cap.
  systemd.settings.Manager = 
    {
      DefaultTimeoutStopSec = "30s";
      DefaultTimeoutAbortSec = "30s";
    };

  networking.hostName = "nixos-maike-pc"; # Define your hostname.

  fileSystems = {
    "/mnt/seagate-hdd-2tb" = {
      device = "/dev/disk/by-uuid/B686BA9786BA5817";
      fsType = "ntfs-3g"; # usually ntfs but it does not support steam games and writing as it seems
      options = [
        "rw"
        "uid=1000"
      ]; # also needed for steam games to run on ntfs uid = id of current user
    };

    "/mnt/programs" = {
      device = "/dev/disk/by-uuid/CA5E85815E856753";
      fsType = "ntfs-3g"; # usually ntfs but it does not support steam games and writing as it seems
      options = [
        "rw"
        "uid=1000"
      ]; # also needed for steam games to run on ntfs uid = id of current user
    };

    "/mnt/win10-32bit" = {
      device = "/dev/disk/by-uuid/1666A92766A90897";
      fsType = "ntfs-3g"; # usually ntfs but it does not support steam games and writing as it seems
      options = [
        "rw"
        "uid=1000"
      ]; # also needed for steam games to run on ntfs uid = id of current user
    };
  };

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable the X11 windowing system.

  # Enable Bluetooth Driver for Multiple Tablets
  # services.xserver.digimend.enable = true;
  # Enable/Install Floorp

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.

  home-manager = {
    extraSpecialArgs = {inherit inputs;};
    # backupFileExtension = "bak";
    users = {
      "maike" = import ./home.nix;
    };
  };

  # Optimising responsiveness
  powerManagement.cpuFreqGovernor = "performance"; # default was schedutil which automatically sets the value: https://www.kernel.org/doc/Documentation/cpu-freq/governors.txt
  # Load AMDGPU drivers for xorg

  # services.xserver.videoDrivers = ["amdgpu"];
  # Enable OpenGL / AMD Drivers for internal GPU - just a test
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # needed for Steam and 32-bit games
  };

  # INSTALL NVIDIA DRIVERS
  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];
  # hardware.graphics.enable = true;
  hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
    # of just the bare essentials.
    powerManagement.enable = true;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of
    # supported GPUs is at:
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
    # Only available from driver 515.43.04+
    open = false;

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.legacy_580;

    # prime = {
    #CHOSE ONE!
    # 01. PRIME Sync and Offload Mode cannot be enabled at the same time
    # keeps nvidia card active even when not in use, except if called for via cli to put it to sleep
    # sync.enable = true;

    # 02. Offload to Nvidia GPU must be done via cli manually!
    # offload = {
    #   enable = true;
    #   enableOffloadCmd = true;
    # };

    # 03. Experimental - resverse Prime output sink - uses iGPU for output and dGPU for rendering
    # reverseSync.enable = true;
    # Enable if using an external GPU
    # allowExternalGpu = false;

    # Use the correct BusID here, can be found with lshw -c display and needs to be written into this format
    # amdgpuBusId = "PCI:35:0:0"; #This value is bullshit, so please delete if not working
    #   nvidiaBusId = "PCI:29:0:0";
    # };
  };

  # Enable VR with Monado / OpenXR and SteamVR
  # services.monado = {
  #   enable = true;
  #   defaultRuntime = true; # Register as default OpenXR runtime
  # };
  # systemd.user.services.monado.environment = {
  #   STEAMVR_LH_ENABLE = "1";
  #   XRT_COMPOSITOR_COMPUTE = "1";
  # };
  # Enable git-lfs to use hand trackers in VR
  programs.git = {
    enable = true;
    lfs.enable = true;
  };
  # STEAMVR kernel cap_sys_nice patch - AMD-specific, not applicable for nvidia systems
  # boot.kernelPatches = [
  #   {
  #     name = "amdgpu-ignore-ctx-privileges";
  #     patch = pkgs.fetchpatch {
  #       name = "cap_sys_nice_begone.patch";
  #       url = "https://github.com/Frogging-Family/community-patches/raw/master/linux61-tkg/cap_sys_nice_begone.mypatch";
  #       hash = "sha256-Y3a0+x2xvHsfLax/uwycdJf3xLxvVfkfDVqjkxNaYEo=";
  #     };
  #   }
  # ];
  # stylix.base16Scheme = "{pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";
  # stylix.image = /home/maike/Pictures/wallpaper/1013625.png;
  # services.displayManager.sddm = {
  #   enable = true;
  #   wayland.enable = true;
  #   package = pkgs.kdePackages.sddm;
  #   theme = "sddm-astronaut-theme";
  # };

  # Enabling qmk vial
  services.udev.packages = with pkgs; [
    vial
    via
  ];
  # Install FireFoxPWA Addon
  # programs.firefox = {
  #   package = pkgs.firefox;
  #   nativeMessagingHosts.packages = [ pkgs.firefoxpwa ];
  # };

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  environment.systemPackages = with pkgs; [
    # would be pkgs.packagename without the with pkgs;
  ];

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

  # For GSK_RENDERER issue with gtk and wayland
  # environment.variables = {
  #   GSK_RENDERER = "ngl";
  #   # GSK_RENDERER = "gl";
  #   # GSK_RENDERER = "opengl";
  # };
}
