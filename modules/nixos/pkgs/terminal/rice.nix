{ config, pkgs, inputs, lib, ... }:
{
  environment.systemPackages = with pkgs; [

    fastfetch
    cava
    cbonsai
    pipes-rs
    cmatrix

  ];
}
