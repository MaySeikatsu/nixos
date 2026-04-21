{pkgs, ...}:{
  services ={
    # Enable sound with pipewire.
    pulseaudio.enable = false;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;

      # For Screensharing Support:
      # media-session.enable = true; # Required for Screenshare (Discord, OBS, Teams) #out of date use wrieplumber
      # x11.enable = true; # For XWayland Share/Apps
      wireplumber.enable = true; # For Device Management
    };
  };
  environment.systemPackages = with pkgs; [
    easyeffects
    pavucontrol # audio volume and device control
    qjackctl
  ];
}
