{...}:
{
  wayland.windowManager.hyprland.settings = {
    exec-once = [
      "hyprpanel"
      #"waybar &"
      # "hyprpaper"
      # "swww-daemon & swww img ~/Pictures/"
      # "swww init & swww ~/Pictures/" 
      "swww-daemon &"

      #"nm-applet &"
      # "[workspace 1 silent] obsidian"
      # "[workspace specialworkspace] ticktick"

      "hyprctl dispatch workspace 1" # To set main monitor to main screen by starting the first workspace on that monitor and give it the right monitor id
    ];
  };
}
