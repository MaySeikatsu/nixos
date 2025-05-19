{ config, pkgs, inputs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./../configuration-shared.nix
      ./hardware-configuration.nix
    ];
  
  # Variables that can be called from nix script 

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
 # boot.loader.grub = {
  #   enable = true;
  #   efiSupport = true;
  # };

  #Enable Hibernate
  systemd.sleep.extraConfig =
  ''
    AllowSuspend = yes
    AllowHibernation = yes
  '';

  networking.hostName = "nixos-legion"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable the X11 windowing system.

  # Enable Custom SDDM Theme in sddm-theme config
  # Trying to get astronaut sddm theme working
  # services.xserver = {
  #   enable = true;
  #   displayManager = {
  #     sddm.enable = true;
  #     sddm.theme = "${import ../../pkgs/sddm-astronaut-theme.nix { inherit pkgs; }}";
  #   };
  # };


  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # to search for pkgs do nix search nixpkgs $name
  environment.systemPackages = with pkgs; [ #would be pkgs.packagename without the with pkgs;
    lenovo-legion
    # inputs.legionrgb

  ];

  home-manager = {
    extraSpecialArgs = {inherit inputs;};
    # backupFileExtension = "bak";
    users = {
      "maike" = import ./home.nix;
    };
  };

  fileSystems."/mnt/archlinux" = {
    device = "/dev/disk/by-uuid/60fefd51-a584-45fe-9b84-0288cf747160";
    fsType = "ext4";
  };

  fileSystems."/mnt/2tb-drive" = {
    device = "/dev/disk/by-uuid/925EFF8B5EFF667F";
    fsType = "ntfs-3g"; #usually ntfs but it does not support steam games and writing as it seems
    options = ["rw" "uid=1000"]; # also needed for steam games to run on ntfs uid = id of current user
  };

  # fileSystems."/mnt/2tb-drive" = {
  #   device = "/dev/disk/by-uuid/925EFF8B5EFF667F";
  #   fsType = "ntfs";
  #   options = ["defaults" "user" "rw" "utf8" "noauto" "umask=000" ];
  # };

  # Load AMDGPU drivers for xorg
  # services.xserver.videoDrivers = ["amdgpu"];
  
  
  # Fix issue with brightness
  # boot.kernelParams = [ "amdgpu.backlight=0" ];

  # INSTALL NVIDIA DRIVERS
  # Enable OpenGL
  hardware.graphics = {
    enable = true;
  };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {

    # Modesetting is required.
    modesetting.enable = true;
    videoAcceleration = false;
    # dynamicBoost.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead 
    # of just the bare essentials.
    powerManagement.enable = true; # not really needed but battery left time was shown higher even though it didn't change gpu behavior

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = true; # Important for battery life
    # powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of 
    # supported GPUs is at: 
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    # Only available from driver 515.43.04+
    open = true;

    # Enable the Nvidia settings menu,
	# accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.beta;

    # GPU Power Management with Optimus PRIME on Multi GPU Setups:
    prime = {
      #CHOSE ONE!
      # 01. PRIME Sync and Offload Mode cannot be enabled at the same time
      # keeps nvidia card active even when not in use, except if called for via cli to put it to sleep
      # sync.enable = true; 

      # 02. Offload to Nvidia GPU must be done via cli manually!
      offload = {
        enable = true;
        enableOffloadCmd = true; 
      };

      # 03. Experimental - resverse Prime output sink - uses iGPU for output and dGPU for rendering
      # reverseSync.enable = true;
      # Enable if using an external GPU
      # allowExternalGpu = false;

      # Use the correct BusID here, can be found with lshw -c display and needs to be written into this format
      amdgpuBusId = "PCI:35:0:0";
      nvidiaBusId = "PCI:01:0:0";
    };
  };
  

  # STEAMVR kernel cap_sys_nice patch for amd gpus - not needed on this system
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
  
  # Install FireFoxPWA Addon
  # programs.firefox = {
  #   package = pkgs.firefox;
  #   nativeMessagingHosts.packages = [ pkgs.firefoxpwa ];
  # };


  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

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
}
