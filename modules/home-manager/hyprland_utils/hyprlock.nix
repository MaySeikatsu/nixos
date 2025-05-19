{pkgs, ...}:
{
  programs.hyprlock = {
    enable = true;
    settings.background.blur_passes = 3;
    # settings = {
    #   general = {
    #       disable_loading_bar = true;
    #       grace = 600;
    #       hide_cursor = true;
    #       no_fade_in = false;
    #     };
    #
    #   # commented out for stylix
    #   background = [
    #     {
    #       path = "~/Pictures/wallpaper/1358528.png";
    #       blur_passes = 2; #3;
    #       blur_size = 3; #8;
    #
    #     }
    #   ];
    #
    #   input-field = [
    #     {
    #       size = "180, 40";
    #       position = "0, -50";
    #       monitor = "";
    #       dots_center = true;
    #       fade_on_empty = false;
    #       # font_color = "rgba(202, 211, 245, 1.0)";
    #       # inner_color = "rgba(91, 96, 120, 0.5)";
    #       #outer_color = "rgba(24, 25, 38, 0.5)";
    #       outline_thickness = 2;
    #       # shadow_passes = 1;
    #     }
    #   ];
    #   label = [
    #     {
    #       monitor = "";
    #       text = "$TIME";
    #       # text_align = "center";
    #       font_size = 96;
    #       position = "0,125";
    #       halign = "center";
    #       valign = "center";
    #     }
    #   ];
    # };
  };
}
