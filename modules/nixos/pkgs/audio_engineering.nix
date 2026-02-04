{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    easyeffects

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
