{ pkgs, inputs, ... }:
let
  # system = "x86_64-linux";
  home.packages = inputs.nixcord.homeManagerModules.nixcord."x86_64-linux";
in {
  programs.nixcord = {
    enable = true;
    # vesktop = { enable = true; };
    discord = {
      enable = true;
      package = pkgs.discord;
      vencord = {
        enable = true;
        unstable = true;
      };
    };
    # quickCss = "some CSS";  # quickCSS file
    config = {
      useQuickCss = true; # use out quickCSS
      themeLinks = [ # or use an online theme
        "https://refact0r.github.io/system24/theme/system24.theme.css"
      ];

      # frameless = true; # set some Vencord options
      # plugins = {
      #   hideAttachments.enable = true;    # Enable a Vencord plugin
      #   ignoreActivities = {    # Enable a plugin and set some options
      #     enable = true;
      #     ignorePlaying = true;
      #     ignoreWatching = true;
      #     ignoredActivities = [ "someActivity" ];
      #   };
      # };
    };
    extraConfig = {
      # Some extra JSON config here
      # ...
    };
  };
}
