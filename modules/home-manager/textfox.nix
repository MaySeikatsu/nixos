{ inputs, pkgs, ... }:
{
  # https://github.com/adriankarlen/textfox
  # imports = [ inputs.textfox.homeManagerModules.default ];

  textfox = {
    enable = true;
    profile = "default";
    config = {
      background = {
        # color = "#123456";
      };
      border = {
        # color = "#654321";
        width = "2px";
        transition = "1.0s ease";
        radius = "3px";
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
