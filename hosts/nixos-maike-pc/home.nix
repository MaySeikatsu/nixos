{ config, inputs, pkgs, ... }:
{
  imports = [
    ./../home-shared.nix
  ];
  # my.git.workDir = "/home/maike/Projects/";

  programs.monado-rift = {
  # Rift CV1 user-side VR bits: OpenXR runtime manifest (Steam's container
  # only reads it from XDG_CONFIG_HOME), xrizer as the OpenVR runtime and the
  # monado-vr-wrap Steam launch wrapper (both default-on). The monado service
  # itself is system-side (services.monado in configuration.nix).
    enable = true;
    service.enable = false;
    # In-VR desktop + dashboard, auto-started with the monado service.
    # Show/hide: double-tap Y (left controller); dashboard: left-wrist watch.
    wayvr.enable = true;
  };

  wayland.windowManager.hyprland.settings = {
    env = [
          "AQ_DRM_DEVICES,/dev/dri/card1" #/dev/dri/card1"# THIS SETTING IS HARDCODED FOR THE LEGION DEVICE should also work for the pc though, but does the exact opposite (on legion uses iGPU on PC uses dGPU)
    ];
  };
}
