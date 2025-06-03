{inputs, config, pkgs, ... }:

{
  # imports = [
  #   # Import the nixCats module
  #   inputs.nixCats-nvim.homeModule
  # ];

  programs.neovim = {
    enable = true;
    # Add extra packages as needed
    extraPackages = with pkgs; [
      lua-language-server
      ripgrep
      # ...other tools
    ];
    # nixCats will handle plugins and LazyVim setup
  };
}

