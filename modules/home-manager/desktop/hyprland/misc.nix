{ ... }:
{
  wayland.windowManager.hyprland.extraConfig =
    # might not work, check later to improve battery life
    ''
      misc {
        vfr = true
        animate_manual_resizes = true
        animate_mouse_windowdragging = false
        enable_swallow = false #hide terminal after app launch

        render_unfocused_fps = 15 #default anyway
      }
      ecosystem {
        no_donation_nag = true
        no_update_news = false
      }
      binds {
        movefocus_cycles_fullscreen = false # cycles fullscreen window instead of moving cursor to next
      }

    '';
}
