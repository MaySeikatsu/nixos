{...}:
{
  wayland.windowManager.hyprland.settings = {
    exec-once = [
      "hyprpanel"
      #"waybar &"
      # "hyprpaper"
      # "swww-daemon & swww img ~/Pictures/"
      "swww init & swww ~/Pictures/" 
      # "swww-daemon"

      #"nm-applet &"
      # "[workspace 1 silent] obsidian"
      # "[workspace specialworkspace] ticktick"
    ];
  };
}
