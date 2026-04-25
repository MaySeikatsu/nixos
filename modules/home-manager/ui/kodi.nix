{pkgs, ...}: {
  # services.xserver.enable = true;
  # services.xserver.desktopManager.kodi.enable = true;

  # programs.kodi = {
  #   enable = true;
  #   settings = {};
  #   sources = {
  #   };
  #   addonSettings = {};
  # };

  # nixpkgs.config.kodi.enableAdvancedLauncher = true; # conflicts with useGlobalPkgs; move to NixOS module if kodi is re-enabled
  # environment.systemPackages = [
  #   (pkgs.kodi.withPackages (kodiPkgs:
  #     with kodiPkgs; [
  #       jellyfin
  #       inputstream-adaptive
  #     ]))
  # ];
}
# services.cage.enable = true;
# services.cage.program = "${pkgs.kodi-wayland}/bin/kodi-standalone";
#
# services.xserver.enable = true;
# services.xserver.desktopManager.kodi.enable = true;
# nixpkgs.config.kodi.enableAdvancedLauncher = true;
# services.xserver.desktopManager.kodi.package = pkgs.kodi.withPackages (kodiPkgs:
#   with kodiPkgs; [
#     #     jellycon
#     inputstream-adaptive
#     #     youtube
#   ]);

