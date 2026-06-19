{ config, inputs, pkgs, ... }: {
  imports = [ ./../home-shared.nix ];
   
  # my.git.workDir = "/home/maike/Projects/";
  # Add if tlp = ac go 165hz else 60hz
  wayland.windowManager.hyprland.settings = {
    env = [
      # "AQ_DRM_DEVICES,/dev/dri/card1" #/dev/dri/card1"# THIS SETTING IS HARDCODED FOR THE LEGION DEVICE should also work for the pc though, but does the exact opposite (on legion uses iGPU on PC uses dGPU)
      "AQ_DRM_DEVICES,/dev/dri/card2:/dev/dri/card1" # USE THIS WHEN NVIDIA CARD IS ACTIVE TO RUN HYPRLAND ON INTERNAL GPU once its one the DEDICATED CARD BECOMES card2
    ];
    monitor = [
      # Use 60Hz for power saving
      "eDP-1, 2560x1600@60, 0x0, 1"
      # "eDP-1, 2560x1600@90, 0x0, 1"
    ];
  };
}
