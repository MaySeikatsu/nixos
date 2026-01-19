{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  environment.systemPackages = with pkgs; [
    neovim
    wget
    git
    gh
    # kanata
    # curl

    # Terminal Emulators
    # All of them are already in in home-manager
    # kitty
    # ghostty
    # alacritty
    # foot

    cargo
    rust-analyzer
    clippy
    rustfmt
    rustup
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
    fd
    bat # rust
    tealdeer # rust
    ncdu # storage scanning and cleanup tool
    # tokei #rust
    ripgrep # rust
    unzip # nvim

    # Terminal Ressource Managers
    bottom
    powertop
    # nvtopPackages.full

    # For Steam VR (troubleshooting):
    # procps
    # usbutils
    lshw # to show hardware info(needed for nvidia config)

    # nixfmt # nix formatter
    # nixd # lsp
    nil # nix lsp
    alejandra # nix formatter
    statix

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
    opentofu
    tofu-ls
    # terraform-landscape
    # terraform-inventory
    # terraform-mcp-server
    # tfmigrate

    gemini-cli
    geminicommit
    # claude-code

    # Virtualisation like WSL for unix systems:
    lima

    # zed-editor
    # code-cursor
    helix
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
