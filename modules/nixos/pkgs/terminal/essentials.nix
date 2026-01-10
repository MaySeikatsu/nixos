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
    go

    typst
    zathura

    #nodejs
    #bun
    # deno

    # Terminal Utility
    # zsh
    # nushell #already in home-manager
    # tmux
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
    # htop
    bottom
    powertop
    # nvtopPackages.full

    # Terminal File Explorers
    # yazi # terminal file manager
    # ranger
    # mc # midnight-commander

    # For Steam VR (troubleshooting):
    # procps
    # usbutils
    lshw # to show hardware info(needed for nvidia config)

    # nixfmt # nix formatter
    # nixd # lsp
    nil # nix lsp
    alejandra # nix formatter
    vulnix # nix vulnerability checker

    trivy # vulnerability checker
    gitleaks # checking for accidantal leaks of credentials in git repos

    google-cloud-sdk
    azure-cli
    # awscli2
    # localstack
    terraform-local

    terraform
    terragrunt
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

    docker
    podman
    kubectl
    kubernetes-helm
    minikube
    k9s
    k3s

    gemini-cli
    geminicommit
    claude-code

    # Virtualisation like WSL for unix systems:
    lima

    # zed-editor
    # code-cursor
    # helix
    vscode

    # Gaming
    osu-lazer-bin
    prismlauncher

    # Chat
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
    gnupg
    # pinentry
    pinentry-curses
    proton-pass
  ];
}
