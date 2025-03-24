{pkgs, inputs, ...}:
  let
    # system = "x86_64-linux";
    home.packages = inputs.nixcord.homeManagerModules.nixcord."x86_64-linux";
  in
{
  # programs.nixcord.enable = true;
    programs.nixcord = {
    enable = true;
    discord = {
      enable = false;
    #   package = pkgs.discord;
    #   # package = pkgs.vesktop;
    #   vencord = {
    #     enable = true;
    #     unstable = true;
    #   };
    };
      vesktop = {
        enable = true;
      };   

  #   enable = true;  # enable Nixcord. Also installs discord package
  #
  #   quickCss = "some CSS";  # quickCSS file
  #   config = {
  #     useQuickCss = true;   # use out quickCSS
  #     themeLinks = [        # or use an online theme
  #       "https://raw.githubusercontent.com/link/to/some/theme.css"
  #     ];
  #     frameless = true; # set some Vencord options
  #     plugins = {
  #       hideAttachments.enable = true;    # Enable a Vencord plugin
  #       ignoreActivities = {    # Enable a plugin and set some options
  #         enable = true;
  #         ignorePlaying = true;
  #         ignoreWatching = true;
  #         ignoredActivities = [ "someActivity" ];
  #       };
  #     };
  #   };
  #   extraConfig = {
  #     # Some extra JSON config here
  #     # ...
  #   };
    };
}
