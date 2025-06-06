{...}:
{
  wayland.windowManager.hyprland.settings = {
    layerrule = [
      "noanim, hyprpicker"
      "noanim, selection"
    ];
  };
  imports = [
    # ./animations/default.nix
    ./animations/flowy.nix
  ];
}
