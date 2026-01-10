{ pkgs, ... }: {
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        # lock_cmd = "pidof hyprlock || hyprlock";
        lock_cmd = "noctalia-shell ipc call lockScreen lock";
        before_sleep_cmd = "loginctl lock-session";
        # after_sleep_cmd = "hyprctl dispatch dpms on";
      };
      listener = [
        {
          timeout = 300;
          on-timeout = "brightnessctl -sd rgb:kbd_backlight set 0";
          on-resume = "brightnessctl -sd rgb:kbd_backlight";
        }
        {
          timeout = 600;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 1200;
          # on-timeout = "hyprctl dispatch dpms off";
          # on-timeout = "systemctl hibernate || loginctl hibernate";
          on-timeout = "systemctl suspend || loginctl suspend";
          # on-resume = "hyprctl dispatch dpms on";
        }
      ];
    };
  };
}
