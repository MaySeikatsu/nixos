{ config, inputs, pkgs, ... }:
{
  imports = [
    ./../home-shared.nix
  ];

  wayland.windowManager.hyprland.settings = {
    env = [
          "AQ_DRM_DEVICES,/dev/dri/card1" #/dev/dri/card1"# THIS SETTING IS HARDCODED FOR THE LEGION DEVICE should also work for the pc though, but does the exact opposite (on legion uses iGPU on PC uses dGPU)
    ];
  };
}
