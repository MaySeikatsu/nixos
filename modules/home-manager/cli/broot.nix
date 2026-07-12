{...}: {
  # Tree-style file manager (expand/collapse like nvim's snacks/neo-tree).
  # Used by the zellij "ide" layout sidebar and helix Space+B.
  # Shell integrations (br function, cd-on-exit) are enabled by default.
  programs.broot = {
    enable = true;
    settings = {
      # show file sizes/dates panel off by default; toggle inside with :toggle_sizes
      default_flags = "";
    };
  };
}
