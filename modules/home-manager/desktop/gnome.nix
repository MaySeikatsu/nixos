{ config, inputs, pkgs, ... }: {
  dconf = {
    enable = true;
    settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
    settings = {
      # Enable the blur-my-shell extension here by UUID
      "org/gnome/shell".enabled-extensions = [ "blur-my-shell@aunetx" ];

      # Configure blur-my-shell extension options
      "org/gnome/shell/extensions/blur-my-shell" = {
        brightness = 0.85;
        dash-opacity = 0.25;
        sigma = 15; # blur amount
        static-blur = true;
      };

      "org/gnome/shell/extensions/blur-my-shell/panel".blur = false;

      "org/gnome/shell/extensions/blur-my-shell/appfolder" = {
        blur = true;
        style-dialogs = 0;
      };
    };
  };
  # programs = {
  #   gnome = {
  #     enable = true;
  #     settings = {
  #
  #     };
  #   };
  # };
}
