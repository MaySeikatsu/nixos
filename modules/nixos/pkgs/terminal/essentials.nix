{ config, pkgs, inputs, lib, ... }: {
  environment.systemPackages = with pkgs; [

    # Terminal Emulators
    # All of them are already in in home-manager
    # kitty
    # ghostty
    # alacritty
    # foot

    cargo
    rust-analyzer
    rustup
    rustfmt
    rustc
    gcc
    openssl
    rustls-libssl
    # dotnet-sdk_8

    # Terminal Utility
    # zsh
    # nushell #already in home-manager
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
    # yazi # terminal file manager
    # ranger
    # mc # midnight-commander

    # Password Managers
    # pass-wayland
    gopass
    gnupg
    passphrase2pgp
    tomb
    gnupg
    pinentry
    pinentry-curses

    # For Steam VR (troubleshooting):
    # procps
    # usbutils
    lshw # to show hardware info(needed for nvidia config)

    nixfmt # nix formatter
    nixd # lsp
    vulnix # nix vulnerability checker
    trivy # vulnerability checker
    gitleaks # checking for accidantal leaks of credentials in git repos

    google-cloud-sdk
    # azure-cli
    terraform
    terraformer
    terraform-ls
    terraform-docs
    hclfmt
    # terraform-landscape
    # terraform-inventory
    # terraform-mcp-server
    # tfmigrate
    opentofu
    tofu-ls

    # Virtualisation like WSL for unix systems:
    lima

  ];
}
