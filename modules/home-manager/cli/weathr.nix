{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.weathr.homeModules.weathr
  ];

  programs.weathr = {
    enable = true;
    # package = inputs.weathr.packages.${pkgs.stdenv.hostPlatform.system}.default;
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
