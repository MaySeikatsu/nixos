{...}:
{
  wayland.windowManager.hyprland.settings = {
    # master = [
    #   "new_status = master"
    # ];
    env = [
      "XCURSOR_SIZE,24"
      "HYPRCURSOR_SIZE,24"
    ]; 
    # dwindle = [
    #   "pseudotile = true" # Master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
    #   "preserve_split = true" # You probably want this
    # ];
    # misc = [
    #   "force_default_wallpaper = -1" # Set to 0 or 1 to disable the anime mascot wallpapers
    #   "disable_hyprland_logo = false" # If true disables the random hyprland logo / anime girl background. :(
    # ];
  };
}
