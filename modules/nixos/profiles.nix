# Feature toggles: switch whole groups of apps on/off per host, e.g. in
# hosts/<host>/configuration.nix:
#
#   my.ai.enable = false;       # laptop short on disk space
#   my.gaming.enable = false;
#
# Everything defaults to what all hosts had before the toggles existed, so
# nothing changes unless a host opts out. Each toggle is implemented in the file noted
# next to it; anything not covered by a toggle is part of the base system.
{lib, ...}: let
  toggle = default: description:
    lib.mkOption {
      type = lib.types.bool;
      inherit default description;
    };
in {
  options.my = {
    # my.ai (ollama, ComfyUI, A1111, speech) has its own options: modules/nixos/ai

    gaming.enable = toggle true ''
      Steam (+ Proton-GE, gamescope), gamemode, ntsync, Lutris, Heroic,
      Bottles, emulators. modules/nixos/config/gaming.nix
    '';

    coding.enable = toggle true ''
      Editors/IDEs, compilers, language servers, cloud CLIs, coding agents,
      Godot. modules/home-manager/coding
    '';

    photoEditing.enable = toggle true ''
      RAW development and photo editing: RapidRaw, darktable, RawTherapee,
      GIMP. modules/nixos/config/photo-editing.nix
    '';

    videoEditing.enable = toggle true ''
      DaVinci Resolve (GPU wrapper), resolve-transcode and the
      ~/Videos/Resolve-Ingest watch folder. modules/nixos/config/davinci-resolve.nix
    '';

    graphics.enable = toggle true ''
      Drawing, pixel art, vector, 2D animation, 3D: Krita, Aseprite,
      LibreSprite, Pixelorama, Inkscape, Pencil2D, OpenToonz (Flatpak),
      Rnote, Goxel, Blender. modules/nixos/config/graphics.nix
    '';

    vtubing.enable = toggle true ''
      Inochi2D (rigging + live session), PNGTuber Remix, OpenSeeFace face
      tracking, OBS virtual camera. modules/nixos/config/vtubing.nix
    '';

    audioProduction.enable = toggle true ''
      DAWs and synths: Bitwig, Reaper, Ardour, LMMS, Zrythm, Audacity,
      Vital, Helm, Neothesia. modules/nixos/pkgs/audio_engineering.nix
    '';

    virtualisation.enable = toggle true ''
      Docker, Podman, libvirt/virt-manager. modules/nixos/virtualisation.nix
    '';
  };
}
