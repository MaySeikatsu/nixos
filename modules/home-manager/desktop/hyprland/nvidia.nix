{...}: {
  wayland.windowManager.hyprland.settings = {
    env = [
      "LIBVA_DRIVER_NAME,nvidia"
      "__GLX_VENDOR_LIBRARY_NAME,nvidia"
      # "GMB_BACKEND,nivida-drm" #for hestia fix
      "__GL_VRR_ALLOWED,1"
      "WLR_DRM_NO_ATOMIC,1"
      # "MOZ_ENABLE_WAYLAND,1" #added for hestia
      # "AQ_DRM_DEVICES,/dev/dri/card2" #/dev/dri/card1"# THIS SETTING IS HARDCODED FOR THE LEGION DEVICE should also work for the pc though, but does the exact opposite (on legion uses iGPU on PC uses dGPU)
    ];
    cursor = {
      no_hardware_cursors = true;
    };
  };
}
