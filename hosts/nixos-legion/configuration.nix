{ config, pkgs, inputs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./../configuration-shared.nix
      ./hardware-configuration.nix
    ];

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

  # For Kanata enable uinput
  boot.kernelModules = ["uinput"];
  hardware.uinput.enable = true;


  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # to search for pkgs do nix search nixpkgs $name
  environment.systemPackages = with pkgs; [ #would be pkgs.packagename without the with pkgs;

  ];
  
  home-manager = {
    extraSpecialArgs = {inherit inputs;};
    backupFileExtension = "bak";
    users = {
      "maike" = import ./home.nix;
    };
  };

  # # Enable Zoxide
  # home-manager.users.maike = {
  #   programs.zoxide.enable = true;
  # };

 # Enable Kanata (with config directly in nix file)
services.kanata = {
  enable = true;
  keyboards = {
    internalKeyboard = {
      # devices = [
# 	# replace with own devices
#         #   "/dev/input/by-path/platform-i8042-serio-0-event-kbd"
#         #   "/dev/input/by-id/usb-Framework_Laptop_16_Keyboard_Module_-_ANSI_FRAKDKEN0100000000-event-kbd"
#         #   "/dev/input/by-id/usb-Framework_Laptop_16_Keyboard_Module_-_ANSI_FRAKDKEN0100000000-if02-event-kbd"
# ];
extraDefCfg = "process-unmapped-keys yes";
config = ''
  (defsrc
 	    esc  f1   f2   f3   f4   f5   f6   f7   f8   f9   f10  f11  f12        prnt slck pause
   grv  1    2    3    4    5    6    7    8    9    0    -    =    bspc  ins  home pgup  nlck kp/  kp*  kp-
   tab  q    w    e    r    t    y    u    i    o    p    [    ]    \     del  end  pgdn  kp7  kp8  kp9  kp+
   caps a    s    d    f    g    h    j    k    l    ;    '    ret                        kp4  kp5  kp6
   lsft z    x    c    v    b    n    m    ,    .    /    rsft                 up         kp1  kp2  kp3  kprt
   lctl lmet lalt           spc            ralt rmet cmp  rctl            left down rght  kp0  kp.
  )
 	   (defvar
   tap-time 300
   hold-time 200

   ;; Set tap/hold time for layer tap-hold
   ;;layer-tap-time 200
   ;;layer-hold-time 160

   ;; Set tap/hold time for space tap-hold
   spc-tap-time 400
   spc-hold-time 400

   ;; Set tap/hold time for homerow mods
   ctl-tap 200
   alt-tap 200
   ;;sft-tap 200
   ;;met-tap 200

   ctl-hold 150
   alt-hold 170
   ;;sft-hold 125
   ;;met-hold 200
 )
  (defalias
   caps (tap-hold 100 100 esc lctl)
   a (multi f24 (tap-hold $tap-time $hold-time a lmet))
   s (multi f24 (tap-hold $tap-time $hold-time s lalt))
   d (multi f24 (tap-hold $tap-time $hold-time d lsft))
   f (multi f24 (tap-hold $tap-time $hold-time f lctl))
   j (multi f24 (tap-hold $tap-time $hold-time j rctl))
   k (multi f24 (tap-hold $tap-time $hold-time k rsft))
   l (multi f24 (tap-hold $tap-time $hold-time l ralt))
   ; (multi f24 (tap-hold $tap-time $hold-time ; rmet))
  )

 ;; ---Base Layer for Kanata---
 (deflayer base
   esc  f1   f2   f3   f4   f5   f6   f7   f8   f9   f10  f11  f12        prnt slck pause
   grv  1    2    3    4    5    6    7    8    9    0    -    =    bspc  ins  home pgup  nlck kp/  kp*  kp-
   tab  q    w    e    r    t    y    u    i    o    p    [    ]    \     del  end  pgdn  kp7  kp8  kp9  kp+
  @lesc @am  @sa  @ds  @fc  g    h    @jc  @ks  @la  @;m  '    ret                        kp4  kp5  kp6
   lsft z    x    c    v    b    n    m    ,    .    /    rsft                 up         kp1  kp2  kp3  kprt
  @chom lmet @aend          spc            ralt rmet cmp  rctl            left down rght  kp0  kp.
 )
 	(deflayer nav1 
   _    _    _    _    _    _    _    _    _    _    _    _    _          _    _    _
   _    _    _    _    _    _    _    _    _    _    _   RA-s  _    _     _    _    _     _    _    _    _
   _ A-left up A-rght  _    _    _    C-v  C-c  C-x  _   RA-y  _    _     _    _    _     _    _    _    _
   _  left down rght   _    _    left down up  rght RA-p RA-q  _                          _    _    _
   _    _    _    _    _    _    _    _    _    _    _    _                    _          _    _    _    _
   _    _    _              _              _    _    _    _               _    _    _     _    _
 )

 (defalias

 ;;Define Layer-Alias
   nav1 (layer-toggle nav1)

 ;;Define Key-Alias and functions
   lesc (tap-hold-press $tap-time $hold-time esc @nav1) 
   lspc (tap-hold-press $spc-tap-time $spc-hold-time spc @nav1)

   chj (chord jkesc j)
   chk (chord jkesc k)

   chom (tap-hold $ctl-tap $ctl-hold home lctrl)
   aend (tap-hold $alt-tap $alt-hold end lalt)

 ;;Homerow Mods
   am (tap-hold $tap-time $hold-time a lmet)
   sa (tap-hold $tap-time $hold-time s lalt)
   ds (tap-hold $tap-time $hold-time d lsft)
   fc (tap-hold $tap-time $hold-time f lctl)

   jc (tap-hold $tap-time $hold-time @chj rctl)
   ks (tap-hold $tap-time $hold-time @chk rsft)
   la (tap-hold $tap-time $hold-time l ralt)
   ;m (tap-hold $tap-time $hold-time ; rmet)

 ;;Alt Keys (figure out syntax to use alias for multiple key presses)
 ;;  @bck (A-left)
 ;;  @fwd (A-right)
 )

 (defchords jkesc 100
   (j    ) j
   (   k ) k
   (j  k ) esc
 )
'';
       };
     };
   };

  # Troubleshooting for steamvr not detecting hardware
  hardware.steam-hardware = {
    enable = true;
  };

  # Load AMDGPU drivers for xorg
  # services.xserver.videoDrivers = ["amdgpu"];

  # INSTALL NVIDIA DRIVERS
  # Load nvidia driver for Xorg and Wayland
  # services.xserver.videoDrivers = ["nvidia"];
  # hardware.nvidia = {
  #   # Modesetting is required.
  #   modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead 
    # of just the bare essentials.
      # powerManagement.enable = true;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    # powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of 
    # supported GPUs is at: 
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    # Only available from driver 515.43.04+
    # open = false;

    # Enable the Nvidia settings menu,
	# accessible via `nvidia-settings`.
    # nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
  #   package = config.boot.kernelPackages.nvidiaPackages.stable;
  # };
  
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
