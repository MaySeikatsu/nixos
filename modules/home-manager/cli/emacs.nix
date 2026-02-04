{...}: {
  programs.emacs = {
    enable = false;
    extraPackages = epkgs: [
      epkgs.nix-mode
      epkgs.nixfmt
    ];
  };
}
