{ config, inputs, pkgs, ... }:
{
  imports = [
    ./../home-shared.nix
  ];

  wayland.windowManager.hyprland.settings = {
    env = [
          "AQ_DRM_DEVICES,/dev/dri/card2" #/dev/dri/card1"# THIS SETTING IS HARDCODED FOR THE LEGION DEVICE should also work for the pc though, but does the exact opposite (on legion uses iGPU on PC uses dGPU)
          # "AQ_DRM_DEVICES,/dev/dri/card1" # USE THIS WHEN NVIDIA CARD IS ACTIVE TO RUN HYPRLAND ON INTERNAL GPU once its one the DEDICATED CARD BECOMES CARD1 instead of the intergrted card
    ];
  };
}
