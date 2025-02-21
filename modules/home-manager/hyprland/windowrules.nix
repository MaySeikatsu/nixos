{...}:
{
  wayland.windowManager.hyprland.settings = {
    windowrule = [
      "float,title:^(Open)$"
      "float,title:^(Choose Files)$"
      "float,title:^(Save As)$"
      "float,title:^(Confirm to replace files)$"
      "float,title:^(File Operation Progress)$"
      "float,class:^(xdg-desktop-portal-gtk)$"
    ];
    layerrule = [
      "blur,rofi"
      "blur, waybar"
      # "blur, hyprpanel"
    ];
  };
}
