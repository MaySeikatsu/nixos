{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    reaper
    audacity
    # tenacity
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
