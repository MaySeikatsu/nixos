{...}:
{
  wayland.windowManager.hyprland.settings = {
    exec-once = [
      "~/.config/nixos/scripts/swww/swww_wallpapersync.sh" #to create hyprland colors file the remove the source error
      "hyprpanel"
      # "quickshell -p ~/.config/quickshell/zaphkiel/Zaphkiel/users/dots/quickshell/kurukurubar/"
      # "nix run github:Rexcrazy804/Zaphkiel#quickshell"
      # "nix shell github:Rexcrazy804/Zaphkiel#quickshell"
      #"waybar &"
      #"ashell &"
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
