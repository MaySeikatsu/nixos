{pkgs, ...}: {
  # The icon theme and the pointer are rose-pine-moon's whichever way the theming switch is set (theming/kurashi.nix).
  home.pointerCursor = {
    enable = true;
    name = "BreezeX-RosePine-Linux";
    package = pkgs.rose-pine-cursor;
    size = 24;
    gtk.enable = true;
  };

  gtk = {
    enable = true;
    iconTheme = {
      name = "rose-pine-moon";
      package = pkgs.rose-pine-icon-theme;
    };
    # theme = {
    #   name = "adwaita";
    #   package = pkgs.gnome.gnome-themes-extra;
    # };
    # iconTheme = {
    #   name = "Papirus-Dark";
    #   packages = pkgs.papirus-icon-theme;
    # };
    #theme.packages = pkgs.catppuccin-gtk.override {
    #accents = ["mauve"]; # You can specify multiple accents here to output multiple themes
    #size = "standard";
    #variant = "mocha";
    #};
    #theme.name = "catppuccin-Dark";
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4 = {
      theme = null;
      extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };
      # extraCss = {
      #
      # }
    };
    # font = {
    #   name = "JetBrainsMono Nerd Font";
    #   size = 12;
    # };
  };
}
