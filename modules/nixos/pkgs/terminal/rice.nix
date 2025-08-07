{ config, pkgs, inputs, lib, ... }: {
  environment.systemPackages = with pkgs; [

    fastfetch
    macchina # neofetch alt rust
    cava
    cavalier
    cbonsai
    pipes-rs
    cmatrix
    rsclock
    # steam-tui
    discordo # discord cli client
    bluetui
    # spotify-player
    # ytui-music
    manga-tui
    ani-cli
    taskwarrior-tui

  ];
}
