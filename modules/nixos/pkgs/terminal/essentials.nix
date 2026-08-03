{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  environment.systemPackages = with pkgs; [
    # Terminal Emulators
    # All of them are already in in home-manager
    # kitty
    # ghostty
    # alacritty
    # foot

    typst
    zathura

    # Terminal Utility
    lsd
    fzf
    fd
    bat # rust
    tealdeer # rust
    ncdu # storage scanning and cleanup tool

    # Terminal Ressource Managers
    bottom
    powertop
    # nvtopPackages.full

    # For Steam VR (troubleshooting):
    # procps
    # usbutils
    lshw # to show hardware info(needed for nvidia config)

    # Virtualisation like WSL for unix systems:
    lima

    # Gaming
    osu-lazer-bin
    prismlauncher

    # Chat
    xrizer
    vesktop # vencord desktop client without overwriting the official discord binary
    element-desktop
    signal-desktop
    beeper
    beeper-bridge-manager
    fluffychat

    # Password Managers
    # pass-wayland
    gopass
    gopass-jsonapi
    # gopass-hibp # haveIbeenPwned?
    gnupg
    # passphrase2pgp
    # tomb
    # pinentry

    # Sops encryypt
    age
    sops
    ssh-to-age

    pinentry-curses
    proton-pass
  ];
}
