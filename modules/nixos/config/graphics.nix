# Drawing, pixel art, vector, 2D animation and 3D.
# Toggle: my.graphics.enable (modules/nixos/profiles.nix)
{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf config.my.graphics.enable {
    environment.systemPackages = with pkgs; [
      # Painting / drawing
      krita
      rnote # sketching and handwritten notes (pen tablets)
      # Pixel art
      aseprite
      libresprite
      pixelorama # pixel art + animation, FOSS
      # Vector
      inkscape
      # 2D animation (OpenToonz: Flatpak below)
      pencil2d
      # 3D / voxels
      goxel

      # Blender from nixpkgs (binary cache, Cycles renders on the CPU).
      # The CUDA build (blender.override { cudaSupport = true; }) compiled
      # Blender + OpenUSD locally on every flake update, ~1 h+ each time;
      # dropped 2026-10-04. GPU rendering without compiling: package the
      # official blender.org build, whose bundled CUDA/OptiX kernels found the
      # GTX 1060 in a quick test.
      blender
    ];

    # OpenToonz (Studio Ghibli's 2D animation suite) isn't in nixpkgs and
    # upstream ships no Linux build, only Flathub. Installed once from
    # Flathub (needs the flathub remote, see flatpak-repo in
    # configuration-shared.nix); updates come with `flatpak update`.
    # Turning the toggle off doesn't uninstall it:
    # `flatpak uninstall io.github.OpenToonz`.
    systemd.services.flatpak-opentoonz = {
      description = "Install OpenToonz from Flathub";
      wantedBy = ["multi-user.target"];
      wants = ["network-online.target"];
      after = ["network-online.target" "flatpak-repo.service"];
      path = [pkgs.flatpak];
      serviceConfig.Type = "oneshot";
      script = ''
        flatpak info --system io.github.OpenToonz >/dev/null 2>&1 \
          || flatpak install --system --noninteractive flathub io.github.OpenToonz
      '';
    };
  };
}
