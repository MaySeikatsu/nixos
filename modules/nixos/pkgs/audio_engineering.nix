{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    reaper
    tenacity
    # yabridge
    ardour
    # audacity
    # bitwig-studio
    # neosynthesia
    neothesia

    # Synthesizer
    vital
    helm
  ];
}
