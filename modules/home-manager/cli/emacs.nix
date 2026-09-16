# Doom Emacs — hybrid setup.
#
# Nix owns: the Emacs binary, every external tool (LSP servers, linters,
# formatters, fonts, vterm's C module, gopass, …) and the daemon.
# Doom owns: elisp packages via `doom sync` (checkout in ~/.config/emacs).
# Our Doom config (init/config/packages.el) lives in this repo under
# ressources/dots/doom and is symlinked *out of store* so edits apply
# instantly without a rebuild.
#
# First-time bootstrap (once, by hand):
#   git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
#   doom install          # ~/.config/emacs/bin is on PATH via home.sessionPath
#   doom sync             # after every change to init.el / packages.el
#   systemctl --user restart emacs
#
# Overview note: obsidian → personal (main)/3 - Ressources/Programs/Doom Emacs.md
{
  config,
  pkgs,
  ...
}: let
  doomDir = "${config.home.homeDirectory}/.config/nixos/ressources/dots/doom";
in {
  programs.emacs = {
    enable = true;
    # pgtk = native Wayland. NOT emacs-gtk: with GTK_IM_MODULE=wayland set in
    # the session, the X11 build segfaults in im-wayland.so on frame creation.
    package = pkgs.emacs-pgtk;
    extraPackages = epkgs: [
      # Packages with C components are easier from Nix than via straight.el.
      # Marked `:built-in` in ressources/dots/doom/packages.el.
      epkgs.vterm
      epkgs.treesit-grammars.with-all-grammars
    ];
  };

  # Daemon: `emacsclient -c` opens a frame instantly.
  services.emacs = {
    enable = true;
    client.enable = true; # .desktop entry "Emacs (Client)"
    defaultEditor = false; # keep hx as $EDITOR
    startWithUserSession = "graphical";
  };
  # The user service doesn't inherit the fish PATH; make LSPs/linters visible.
  systemd.user.services.emacs.Service.Environment = [
    "PATH=${config.home.profileDirectory}/bin:/run/current-system/sw/bin:/run/wrappers/bin:${config.home.homeDirectory}/.config/emacs/bin"
  ];

  home.sessionPath = ["${config.home.homeDirectory}/.config/emacs/bin"];

  # Doom looks for ~/.config/doom before ~/.doom.d.
  xdg.configFile."doom".source = config.lib.file.mkOutOfStoreSymlink doomDir;

  # No `-a ''` fallback: it spawns a second daemon that fights the systemd one.
  home.shellAliases = {
    e = "emacsclient -c -n"; # GUI frame, don't block
    et = "emacsclient -t"; # terminal frame in this pane
  };

  home.packages = with pkgs; [
    # ── core tooling Doom expects ────────────────────────────────────────
    ripgrep
    fd
    git
    gnumake
    cmake # vterm / doom doctor
    libtool
    gcc
    (hunspellWithDicts [hunspellDicts.en_US hunspellDicts.de_DE]) # :checkers spell
    (aspellWithDicts (d: [d.en d.de])) # doom doctor / fallback
    libxml2 # xmllint (:lang data)
    grim # org-download-clipboard screenshots (wayland)
    editorconfig-core-c
    pandoc # org/markdown export
    graphviz # org-babel dot
    plantuml # :lang plantuml (wraps java)
    imagemagick # image-dired / org inline images
    sqlite # org-roam / forge db
    nodejs_22 # several LSP servers
    copilot-language-server # copilot.el

    # ── fonts ───────────────────────────────────────────────────────────
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only # doom's nerd-icons
    emacs-all-the-icons-fonts
    symbola # emacs fallback font (doom doctor)

    # ── LSP servers / linters / formatters per language ─────────────────
    # nix
    nil
    nixfmt-rfc-style
    statix
    deadnix
    # terraform / hcl
    terraform-ls
    tflint
    # go
    gopls
    gotools # goimports
    gomodifytags
    gotests
    gore
    golangci-lint
    delve # dap
    # rust
    rust-analyzer
    rustfmt
    clippy
    # python
    basedpyright
    ruff
    python3
    python3Packages.pytest
    # typescript / web
    typescript
    typescript-language-server
    vscode-langservers-extracted # html, css, json, eslint
    prettier
    js-beautify
    stylelint
    html-tidy
    # lua
    lua-language-server
    stylua
    # c / c++
    clang-tools # clangd, clang-format
    # c#
    omnisharp-roslyn
    dotnet-sdk
    # yaml / toml / json
    yaml-language-server
    taplo
    # shell
    bash-language-server
    shellcheck
    shfmt
    # markdown
    marksman
    go-grip # markdown preview (+grip)
    # docker / kubernetes
    dockerfile-language-server
    hadolint
    dockfmt
    kubectl
    kubernetes-helm

    # ── org / apps ───────────────────────────────────────────────────────
    gopass # :tools pass (pass-compatible)
    gnupg
  ];
}
