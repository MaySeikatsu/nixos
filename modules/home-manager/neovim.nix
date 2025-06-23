{inputs, config, pkgs, ... }:

{
  # imports = [
  #   # Import the nixCats module
  #   inputs.nixCats-nvim.homeModule
  # ];

  # Creates a wallust.lua file inside of ~/.config/wallust or overwrites it with the given values of the file included in the repo 
  # xdg.configFile."./nvim/lua/plugins/wallust.lua".source = ../../../ressources/dos/nvim/lua/plugins/wallust.lua; #For neovim config to work with wallust

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

