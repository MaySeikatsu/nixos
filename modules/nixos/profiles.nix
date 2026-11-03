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

    craftApps.enable = toggle true ''
      FilmCraft, PhotoCraft, LightCraft, EffectCraft, built from my forks.
      modules/nixos/config/craft-apps.nix
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

    inputAssist.enable = toggle true ''
      AI typing help in every text field via Fcitx5: XType inline
      autocomplete (local model via Ollama) and fcitx5-vinput voice input.
      modules/nixos/config/input-assist.nix
    '';

    searxng.enable = toggle true ''
      SearXNG private meta search on http://127.0.0.1:8080 (also the web
      search for Odysseus and Open WebUI). modules/nixos/config/searxng.nix
    '';

    virtualisation.enable = toggle true ''
      Docker, Podman, libvirt/virt-manager. modules/nixos/virtualisation.nix
    '';

    # Off: every app keeps its Nix default (rose-pine-moon where it has one). On: kurashi styles the apps it can and the
    # theming bridge the rest, from kurashi's theme. The shell runs either way. This host turns it on
    # (hosts/nixos-maike-pc/configuration.nix).
    kurashi-theming.enable = toggle false ''
      kurashi styles niri, foot, ghostty, GTK, Qt and GNOME apps, and the theming bridge renders helix, neovim and fzf,
      from kurashi's theme; off = the Nix default. modules/home-manager/theming/kurashi.nix
    '';

    # Full-screen pointer light and spotlight need niri's main branch: kurashi's niri-main input (849c576), built from
    # source in place of nixpkgs' niri. A long build, and it moves the niri tools around it to niri main as well.
    # Off: the pointer light covers the shell's own surfaces only. modules/nixos/config/niri.nix
    kurashi-pointerLight.enable = toggle false ''
      niri from its main branch, built from source, for kurashi's full-screen pointer light (programs.kurashi.pointerLight).
      modules/nixos/config/niri.nix
    '';
  };
}
