{ config, pkgs, inputs, lib, ... }: {
  environment.systemPackages = with pkgs; [

    # Terminal Emulators
    kitty
    ghostty
    alacritty
    foot

    # Terminal Utility
    # zsh
    nushell
    tmux
    lsd
    fzf
    zoxide
    lazygit
    fd
    bat # rust
    tealdeer # rust
    ncdu # storage scanning and cleanup tool
    # tokei #rust
    ripgrep # rust
    unzip # nvim

    # Terminal Ressource Managers
    btop
    htop
    bottom
    powertop
    nvtopPackages.full

    # Terminal File Explorers
    yazi # terminal file manager
    ranger
    # mc # midnight-commander

    # Password Managers
    pass-wayland
    gopass

    # For Steam VR (troubleshooting):
    # procps
    # usbutils
    lshw # to show hardware info(needed for nvidia config)

  ];
}
