{pkgs, ...}: {
  # Set your time zone.
  time.timeZone = "Europe/Berlin";
  i18n = {
    # Select internationalisation properties.
    defaultLocale = "en_GB.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "de_DE.UTF-8";
      LC_IDENTIFICATION = "de_DE.UTF-8";
      LC_MEASUREMENT = "de_DE.UTF-8";
      LC_MONETARY = "de_DE.UTF-8";
      LC_NAME = "de_DE.UTF-8";
      LC_NUMERIC = "de_DE.UTF-8";
      LC_PAPER = "de_DE.UTF-8";
      LC_TELEPHONE = "de_DE.UTF-8";
      LC_TIME = "de_DE.UTF-8";
    };

    ###############################
    ## Input Method Editor (IME) ## For Japanese
    ###############################
    # This enables "fcitx" as your IME.  This is an easy-to-use IME.  It supports many different input methods.
    # inputMethod.enabled = "fcitx";

    # This enables "mozc" as an input method in "fcitx".  This has a relatively
    # complete dictionary.  I recommend it for Japanese input.
    inputMethod = {
      enable = true;
      ibus.engines = "mozc";
      type = "fcitx5";
      fcitx5 = {
        waylandFrontend = true;
        addons = with pkgs; [
          fcitx5-mozc
          fcitx5-gtk
        ];
      };
    };
  };
}
