{...}: {
  #Maybe call it input
  wayland.windowManager.hyprland.settings = {
    input = {
      kb_layout = "us, de";
      kb_variant = "altgr-intl,";
      kb_options = "grp:win_space_toggle";
      numlock_by_default = true;

      follow_mouse = 1;

      sensitivity = 0;

      touchpad = {
        natural_scroll = true;
      };
    };
    # gestures = {
    #   workspace_swipe = "true";
    # };
  };
}
