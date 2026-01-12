{pkgs, ...}: {
  fonts = {
    fontconfig = {
      enable = true;
      antialias = true;
      subpixel.rgba = "rgb";
      subpixel.lcdfilter = "default";
    };

    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      roboto
      source-sans
      font-awesome
      source-sans
      font-awesome_6
      openmoji-color

      #enabled for end-4-dots
      # rubik
      # nerd-fonts.ubuntu
    ];
  };
}
