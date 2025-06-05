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
    windowrulev2 = [
      "opacity 0.9 0.9,class:^(steam)$"
      "opacity 0.9 0.9,class:^(discord)$"
      "opacity 0.9 0.9,class:^(vesktop)$"
      "opacity 0.9 0.9,class:^(dolphin)$"
      "opacity 0.9 0.9,class:^(spotify)$"
      "opacity 0.9 0.9,class:^(hyprpanel)$"
      "opacity 0.9 0.9,class:^(obsidian)$"
      "opacity 0.9 0.9,class:^(ticktick)$"
      "opacity 0.9 0.9,class:^(tidal-hifi)$"

      # "noborder, class:^(zen-twilight)$" #nett aber not working
      "noborder, floating:1, class:^(zen-twilight)$"
      # "bordercolor rgb(00FF00), !floating:1, class:^(zen-twilight)$"
    ];
    layerrule = [
      "blur,rofi"
      "blur, waybar"
      "blur, hyprpanel"
      "blur, steam"
      "blur, dolphin"
      "blur, spotify"
      "blur, obsidian"
      "blur, ticktick"
      "blur, tidal-hifi"
    ];
  };
}
