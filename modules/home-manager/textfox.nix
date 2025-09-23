{ inputs, pkgs, ... }:
{
  # https://github.com/adriankarlen/textfox
  # imports = [ inputs.textfox.homeManagerModules.default ];

  textfox = {
    enable = true;
    profile = "default";
    config = {
      background = {
        # color = "#232136";
      };
      border = {
        # color = "#EA9A97";
        width = "2px";
        transition = "0.2s ease";
        radius = "15px"; # 2px orig
      };
      displayHorizontalTabs = false;
      displayWindowControls = false;
      displayNavButtons = true;
      displayUrlbarIcons = true;
      displaySidebarTools = false;
      displayTitles = false;
      newtabLogo = "   __            __  ____          \A   / /____  _  __/ /_/ __/___  _  __\A  / __/ _ \\| |/_/ __/ /_/ __ \\| |/_/\A / /_/  __/>  </ /_/ __/ /_/ />  <  \A \\__/\\___/_/|_|\\__/_/  \\____/_/|_|  ";
      # font = {
      #   family = "Fira Code";
      #   size = "15px";
      #   accent = "#654321";
      # };
      sidebery = {
        margin = "1.0rem";
      };
    };
  };
}
# INACTIVE
