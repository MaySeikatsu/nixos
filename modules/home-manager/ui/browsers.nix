{pkgs,lib,inputs,osConfig,...}: let
  # Hardware video decoding (VA-API) in Zen; the driver side is in
  # modules/nixos/config/gpu-acceleration.nix. Set as policies so they apply
  # to every profile on every host; "default" status keeps them changeable
  # in about:config. Check it works: about:support -> Media -> "Hardware
  # decoding", or watch `nvidia-smi` show zen during playback.
  nvidia = osConfig.hardware.nvidia;
  nvidiaOnly =
    lib.elem "nvidia" osConfig.services.xserver.videoDrivers
    && !nvidia.prime.offload.enable
    && !nvidia.prime.sync.enable;
  pref = value: {
    Value = value;
    Status = "default";
  };
  zen = inputs.zen-browser.packages."${pkgs.stdenv.hostPlatform.system}".twilight.override {
    extraPolicies.Preferences =
      {
        "media.ffmpeg.vaapi.enabled" = pref true;
        "media.hardware-video-decoding.force-enabled" = pref true; # NVIDIA is blocklisted by default
        "widget.dmabuf.force-enabled" = pref true;
      }
      // lib.optionalAttrs nvidiaOnly {
        # Pascal's NVDEC has no AV1: with AV1 off YouTube serves VP9, which
        # the GPU decodes, instead of AV1 decoded on the CPU
        "media.av1.enabled" = pref false;
      };
  };
in {
  home.packages = with pkgs; [
    # (pkgs.callPackage ../../../packages/terminal-browser.nix {}) # Disabled: Foot lacks Kitty graphics protocol support.
    microsoft-edge
    # vivaldi
    zen
  ];

  programs = {
    firefox = {
      enable = true; # Install firefox.
      # keep the existing profile location (new HM default is ~/.config/mozilla)
      configPath = ".mozilla/firefox";
    };
  # floorp.enable = true;
  };
  
  textfox = {
    enable = true;
    profiles = ["default"];
    config = {
      background = {
        # color = "#232136";
      };
      border = {
        # color = "#EA9A97";
        width = "2px";
        transition = "0.2s ease";
        radius = "15px"; # 2px orig
      };
      tabs = {
        horizontal.enable = false;
        # vertical.sidebery.margin = "1.0rem";
      };
      displayWindowControls = false;
      displayNavButtons = true;
      displayUrlbarIcons = true;
      displaySidebarTools = false;
      displayTitles = false;
      newtabLogo = "   __            __  ____          A   / /____  _  __/ /_/ __/___  _  __A  / __/ _ \\| |/_/ __/ /_/ __ \\| |/_/A / /_/  __/>  </ /_/ __/ /_/ />  <  A \\__/\\___/_/|_|\\__/_/  \\____/_/|_|  ";
      # font = {
      #   family = "Fira Code";
      #   size = "15px";
      #   accent = "#654321";
      # };
    };
  };
}
