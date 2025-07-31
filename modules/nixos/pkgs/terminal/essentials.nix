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
    # starship
    tmux
    lsd
    fzf
    zoxide
    lazygit
    fd

    # Terminal Ressource Managers
    btop
    htop
    bottom
    nvtopPackages.full

    # Terminal File Explorers
    yazi #terminal file manager
    ranger
    mc #midnight-commander

    # Password Managers
    pass-wayland
    gopass

    ani-cli
  ];
}
