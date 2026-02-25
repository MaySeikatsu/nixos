{inputs, ...}: {
  imports = [
    inputs.weathr.homeModules.weathr
  ];

  programs.weathr = {
    enable = true;
    settings = {
      hide_hud = true;
      silent = true;
      location = {
        auto = false;
        hide = false;
        # Tokyo, Japan
        latitude = 35.6762;
        longitude = 139.6503;
      };
    };
  };
}
