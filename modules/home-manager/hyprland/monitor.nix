{...}:
{
  wayland.windowManager.hyprland.settings = {
    monitor = [
      # "HDMI-A-1, 3840x2160@highrr, auto-left, 1.25, bitdepth, 10"
      # "DP-2, 3840x2160@160, auto-left, 1.25, bitdepth, 10"

      # "HDMI-A-1, 3840x2160@highrr, auto-left, 1.25"
      # "HDMI-A-1, 3840x2160@60, 0x0, 1, bitdepth, 10, cm, hdr"

      # # Autodetect Laptop
      ", preferred, auto-left, 1"
      "DP-10, preferred, auto-left, 1"
      "DP-11, preferred, auto-left, 1"

      # 4k Screen
      "HDMI-A-1, 3840x2160@60, 0x0, 1"
      "DP-2, 3840x2160@143.85, 0x0, 1"
      # HDR
      # "DP-2, 3840x2160@143.85, 0x0, 1, bitdepth, 10, cm, hdr, sdrbrightness, 1.2, sdrsaturation, 0.98"
      
      # 390Hz Screen
      "HDMI-A-2,1920x1080@239.96, auto-left, 1, transform, 1"
      "HDMI-A-1,1920x1080@239.96, auto-left, 1, transform, 1"
      # HDR
      # "HDMI-A-2,1920x1080@239.96, auto-left, 1, transform, 1, bitdepth, 10, cm, hdr, sdrbrightness, 1.2, sdrsaturation, 0.98"

      # "DP-2, 3840x2160@60, 0x0, 1.25"
      # "DVI-D-1, 1440x900@75, 1920x590, 1"
      # "DP-2,1920x1080@360, 0x0, 1"
      # "HDMI-A-2,1920x1080@60, -1920x0, 1"
      
      ];

      workspace = [
        # "name:0,monitor:DP-2" # start workspace one on main monitor (in this case dp-2) to start steam games correctly
        "name:1,monitor:DP-2" # start workspace one on main monitor (in this case dp-2) to start steam games correctly
      ];
    #not working properly yet i think
    # workspace = [
    #   "1,monitor:eDP-2"
    #   "2,monitor:eDP-2"
    #   "3,monitor:eDP-2"
    #   "4,monitor:HDMI-A-2"
    #   "5,monitor:HDMI-A-2"
    #   "6,monitor:HDMI-A-2"
    #   "7,monitor:DVI-D-1"
    #   "8,monitor:DVI-D-1"
    #   "9,monitor:DVI-D-1"
    # ];
  };
}
