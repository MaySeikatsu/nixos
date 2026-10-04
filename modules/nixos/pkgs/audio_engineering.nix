# toggle: my.audioProduction.enable (modules/nixos/profiles.nix)
{
  pkgs,
  lib,
  config,
  ...
}: {
  environment.systemPackages = lib.mkIf config.my.audioProduction.enable (with pkgs; [
    # DAWs
    bitwig-studio # Ableton-like, by ex-Ableton devs (paid; demo without saving/export)
    reaper # flexible all-rounder (paid, fully working 60-day evaluation)
    ardour # FOSS, recording/mixing/mastering
    lmms # FOSS, FL Studio-like pattern workflow
    zrythm # FOSS, modern

    audacity
    # tenacity
    # yabridge
    # neosynthesia
    neothesia

    # Synthesizer
    vital
    helm
  ]);
}
