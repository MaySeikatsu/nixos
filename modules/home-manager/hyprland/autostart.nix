{ ... }: {
  wayland.windowManager.hyprland.settings = {
    exec-once = [
      "~/.config/nixos/scripts/swww/swww_wallpapersync.sh" # to create hyprland colors file the remove the source error
      # "hyprpanel"
      # "noctalia-shell"
      "caelestia-shell"
      # "quickshell -p ~/.config/quickshell/zaphkiel/Zaphkiel/users/dots/quickshell/kurukurubar/"
      # "nix run github:Rexcrazy804/Zaphkiel#quickshell"
      # "nix shell github:Rexcrazy804/Zaphkiel#quickshell"
      #"waybar &"
      #"ashell &"
      #"ironbar &"
      # "hyprpaper"
      # "swww-daemon & swww img ~/Pictures/"
      # "swww init & swww ~/Pictures/" 
      "swww-daemon &"

      # "hyprctl dispatch workspace music" # To set main monitor to main screen by starting the first workspace on that monitor and give it the right monitor id
      # "hyprctl dispatch workspace tasks" # To set main monitor to main screen by starting the first workspace on that monitor and give it the right monitor id
      # "hyprctl dispatch workspace communication" # To set main monitor to main screen by starting the first workspace on that monitor and give it the right monitor id
      # #"nm-applet &"
      # "[workspace tasks silent] ticktick"
      # "[workspace tasks silent] obsidian"
      # "[workspace tasks silent] foot -D ~/Documents/obsidian-sync/"
      # "[workspace communication silent] vesktop"
      # "[workspace music silent] tidal-hifi"
      # "[workspace specialworkspace] ticktick"

      "hyprctl dispatch workspace 1" # To set main monitor to main screen by starting the first workspace on that monitor and give it the right monitor id
    ];
  };
}
