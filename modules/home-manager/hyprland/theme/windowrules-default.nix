{ ... }: {
  wayland.windowManager.hyprland.settings = {
    windowrule = [
      "float,title:^(Open)$"
      "float,title:^(Choose Files)$"
      "float,title:^(Save As)$"
      "float,title:^(Confirm to replace files)$"
      "float,title:^(File Operation Progress)$"
      "float,class:^(xdg-desktop-portal-gtk)$"

      "float,title:^(Picture-in-Picture)$"
      "pin,title:^(Picture-in-Picture)$"
      # "size 709 397, title:^(Picture-in-Picture)$" #good size
      "size 355 199, title:^(Picture-in-Picture)$"
      "move 100%-w-24 100%-w-24, title:^(Picture-in-Picture)$"
    ];
    windowrulev2 = [
      # active / inactive / fullscreen
      "opacity 0.9 0.9,class:^(steam)$"
      "opacity 0.9 0.9,class:^(discord)$"
      "opacity 0.9 0.9,class:^(vesktop)$"
      "opacity 0.9 0.9,class:^(dolphin)$"
      "opacity 0.8 0.8,class:^(spotify)$"
      "opacity 0.9 0.9,class:^(hyprpanel)$"
      "opacity 0.9 0.9,class:^(obsidian)$"
      "opacity 0.9 0.9,class:^(ticktick)$"
      "opacity 0.8 0.8,class:^(tidal-hifi)$"
      "opacity 0.8 0.8,class:^(wofi)$"
      "opacity 0.95 0.95,class:^(foot)$"
      "opacity 1.0 1.0 0.85,class:^(foot)$"
      "opacity 0.9 0.9 0.9,class:^(sherlock)$"
      "xray ,class:^(foot)$"

      "idleinhibit always,class:^(teams-for-linux)$"
      # "noborder, class:^(zen-twilight)$" #nett aber not working
      "noborder, floating:1, class:^(zen-twilight)$"
      # "bordercolor rgb(00FF00), !floating:1, class:^(zen-twilight)$"
      # put this into binds to pin the current window bind = $mainMod, S, pin
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
      "blur, wofi"
      "blur, foot"
      "blur, sherlock"
    ];
  };
}
