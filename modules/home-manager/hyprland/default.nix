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
    ./theme.nix
    ./windowrules.nix
    ./keyboard.nix
  ];
}
