{...}:
{
  wayland.windowManager.hyprland.settings = {
    env = [
    "LIBVA_DRIVER_NAME,nvidia"
    "__GLX_VENDOR_LIBRARY_NAME,nvidia"
    "__GL_VRR_ALLOWED,1"
    "WLR_DRM_NO_ATOMIC,1"
  ];
    cursor = {
      no_hardware_cursors = true;
    };
  };
}
