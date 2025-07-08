{...}:
{
  wayland.windowManager.hyprland.enable = true;
  imports = [
    ./animations.nix
    ./autostart.nix
    ./bind.nix
    ./env.nix
    ./monitor.nix
    ./nvidia.nix
    ./programs.nix
    ./theme-loader.nix
    # ./windowrules.nix #now under theme
    ./keyboard.nix
    ./workspace.nix
    ./misc.nix
  ];
}
