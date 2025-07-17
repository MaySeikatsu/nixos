{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    reaper
    # yabridge
    ardour
    # audacity
    # bitwig-studio
    neosynthesia

  ];
}
