{pkgs, ...}: {
  imports = [
    ./zed-editor.nix
  ];

  home.packages = with pkgs; [
    # Tools
    tree-sitter
    wget
    git
    gh
    ripgrep # rust
    unzip # nvim
    vulnix # nix vulnerability checker
    trivy # vulnerability checker
    gitleaks # checking for accidantal leaks of credentials in git repos
    # tokei #rust - count code
    # curl

    # IDEs and Code Editors
    neovim
    jetbrains.rust-rover
    # zed-editor #enabled via ui/zed-editor
    # helix
    # code-cursor
    vscode

    # Lang, LSP & Linting
    cargo
    # rustup
    rust-analyzer
    clippy
    rustfmt
    rustc
    gcc
    openssl
    pkg-config
    nix-direnv
    rustls-libssl
    cargo-watch
    go
    # dotnet-sdk_8
    # nodejs
    # bun
    # deno

    # Nix Formatter and LSP
    nil # nix lsp to replace of nixd
    alejandra # nix formatter
    statix # Nix Linter

    # Go
    gopls
    gofumpt
    golangci-lint

    # Python
    basedpyright
    ruff

    # C / C++
    clang-tools # provides clangd, clang-format, clang-tidy

    # C#
    omnisharp-roslyn
    csharpier

    # TypeScript / JavaScript
    typescript-language-server
    vscode-langservers-extracted # jsonls, htmlls, cssls
    prettierd
    eslint

    # Kotlin
    kotlin-language-server
    ktfmt
    ktlint

    # Config formats
    yaml-language-server
    taplo
    marksman

    # Lua (LSP + formatter)
    lua-language-server
    stylua

    # Bash / Shell
    bash-language-server
    shfmt
    shellcheck

    # Docker
    dockerfile-language-server-nodejs
    docker-compose-language-service
    hadolint

    # .NET / F#
    fsautocomplete

    # SQL
    sqls
    sqlfluff

    # GCP and Cloud / DevOps
    google-cloud-sdk
    azure-cli
    terraform-local
    terraform
    tflint
    jq
    terragrunt
    terraformer
    terraform-ls
    terraform-docs
    hclfmt
    opentofu
    tofu-ls
    # awscli2
    # localstack
    # terraform-landscape
    # terraform-inventory
    # terraform-mcp-server
    # tfmigrate

    # Vibe
    opencode
    mistral-vibe
    github-copilot-cli
    gemini-cli
    codex
    pi-coding-agent
    ollama
    # lmstudio
    # geminicommit
    claude-code

    # Gamedev
    godot
  ];
}
