# VTubing. Toggle: my.vtubing.enable (modules/nixos/profiles.nix)
#
# - Inochi2D: open-source Live2D alternative. Inochi Creator (Flatpak) rigs a 2D
#   model, inochi-session runs it live with face tracking (feed it
#   OpenSeeFace or a phone app speaking the VMC/VTube Studio protocol).
# - PNGTuber Remix: simple PNG-tuber (images swap with your mic level).
# - OpenSeeFace: webcam face tracker that sends tracking data to
#   Inochi Session (and to VSeeFace/VNyan if run under Wine/Proton).
# - OBS virtual camera (v4l2loopback): show the avatar from OBS as a webcam
#   in Discord, browser calls etc. OBS itself is in the home-manager ui module.
# Live voice changing: Applio's Realtime tab (modules/nixos/ai/voice-changer.nix).
# Windows-only tools (VTube Studio, Warudo) run via Steam + Proton, no Nix needed.
{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf config.my.vtubing.enable {
    environment.systemPackages = with pkgs; [
      # inochi-creator: from Flathub below; the nixpkgs build fails with
      # ldc 1.42 (`objc_opt_isKindOfClass` not found), 2026-10
      inochi-session
      openseeface
      (callPackage ../../../packages/pngtuber-remix.nix {})
    ];

    # Same setup as NixOS' programs.obs-studio.enableVirtualCamera, without
    # installing a second OBS next to the home-manager one.
    boot.extraModulePackages = [config.boot.kernelPackages.v4l2loopback];
    boot.kernelModules = ["v4l2loopback"];
    boot.extraModprobeConfig = ''
      options v4l2loopback devices=1 video_nr=1 card_label="OBS Virtual Camera" exclusive_caps=1
    '';
    security.polkit.enable = true;

    # Turning the toggle off doesn't uninstall it:
    # `flatpak uninstall com.inochi2d.inochi-creator`
    systemd.services.flatpak-inochi-creator = {
      description = "Install Inochi Creator from Flathub";
      wantedBy = ["multi-user.target"];
      wants = ["network-online.target"];
      after = ["network-online.target" "flatpak-repo.service"];
      path = [pkgs.flatpak];
      serviceConfig.Type = "oneshot";
      script = ''
        flatpak info --system com.inochi2d.inochi-creator >/dev/null 2>&1 \
          || flatpak install --system --noninteractive flathub com.inochi2d.inochi-creator
      '';
    };
  };
}
