{ config, pkgs, inputs, lib, ... }:
{
  environment.systemPackages = with pkgs; [

    # Terminal Emulators
    kitty
    ghostty
    alacritty
    foot

    # Terminal Utility
    zsh
    tmux
    lsd
    fzf
    zoxide
    lazygit
    fd

    # Terminal Ressource Managers
    btop
    htop
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
