{ config, pkgs, inputs, lib, ... }:
{
  environment.systemPackages = with pkgs; [

    fastfetch
    cava
    cavalier
    cbonsai
    pipes-rs
    cmatrix
    rsclock
    steam-tui
    discordo # discord cli client

  ];
}
