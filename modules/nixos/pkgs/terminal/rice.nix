{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
{
  environment.systemPackages = with pkgs; [

    fastfetch
    macchina # neofetch alt rust
    cava
    cavalier
    cbonsai
    pipes-rs
    cmatrix
    rsclock
    lolcat
    # steam-tui
    discordo # discord cli client
    bluetui
    spotify-player
    # ytui-music
    manga-tui
    ani-cli
    taskwarrior-tui
    cool-retro-term
  ];
}
