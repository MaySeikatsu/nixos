{pkgs, ...}:
{
  programs.hyprlock = {
    enable = true;
    settings = {
general = {
    disable_loading_bar = true;
    grace = 300;
    hide_cursor = true;
    no_fade_in = false;
  };

  background = [
    {
      path = "screenshot";
      blur_passes = 3;
      blur_size = 8;
    }
  ];

  input-field = [
    {
      size = "200, 50";
      position = "0, -80";
      monitor = "";
      dots_center = true;
      fade_on_empty = false;
      font_color = "rgba(202, 211, 245, 1.0)";
      inner_color = "rgba(91, 96, 120, 0.5)";
      #outer_color = "rgba(24, 25, 38, 0.5)";
      outline_thickness = 5;
      shadow_passes = 2;
    }
  ];
  };
  };
}
