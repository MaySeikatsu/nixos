{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    fastfetch
    # macchina # neofetch alt rust
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
    reddix
    youtube-tui
    mpv
    yt-dlp
    # ytui-music
    manga-tui
    ani-cli
    taskwarrior-tui
    # cool-retro-term
  ];
}
