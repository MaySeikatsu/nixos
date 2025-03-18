{ config, pkgs, inputs, lib, ... }:
{
  environment.systemPackages = with pkgs; [

    # Terminal Emulators
    kitty
    ghostty

    # Terminal Utility
    zsh
    tmux
    lsd
    fzf
    zoxide
    lazygit

    # Terminal Ressource Managers
    btop
    nvtopPackages.full

    # Terminal File Explorers
    yazi #terminal file manager
    ranger
    mc #midnight-commander

    # Password Managers
    pass-wayland
    gopass

  ];
}
