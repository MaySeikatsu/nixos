{
  config,
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ../modules/home-manager/cli
    ../modules/home-manager/desktop
    ../modules/home-manager/terminal
    ../modules/home-manager/theming
    ../modules/home-manager/ui
    ../modules/home-manager/coding

    # ./../modules/home-manager/matugen.nix
    # ./../../modules/home-manager/kanata.nix
    # inputs.stylix.homeModules.stylix
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  programs.shellseikatsu = {
    enable = true;
    # settings = {
    #
    # };
    matugen.enable = true;
  };
  home = {
    username = "maike";
    homeDirectory = "/home/maike";
    stateVersion = "24.11"; # Please read the comment before changing.
    # stateVersion = "26.05"; # Please read the comment before changing.
    packages = [
      # pkgs.hyprpanel
      # pkgs.anyrun
      # pkgs.jetbrains.rider
      # pkgs.jetbrains.rust-rover
      # # It is sometimes useful to fine-tune packages, for example, by applying overrides. You can do that directly here, just don't forget the parentheses. Maybe you want to install Nerd Fonts with a limited number of fonts?
      # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })
      # # You can also create simple shell scripts directly inside your configuration
      # (pkgs.writeShellScriptBin "my-hello" ''
      #   echo "Hello, ${config.home.username}!"
      # '')
    ];
    file = {
      # Home Manager is pretty good at managing dotfiles. The primary way to manage plain files is through 'home.file'.
      # # Building this configuration will create a copy of 'dotfiles/screenrc' in
      # # the Nix store. Activating the configuration will then make '~/.screenrc' a
      # # symlink to the Nix store copy.
      # ".screenrc".source = dotfiles/screenrc;

      # # You can also set the file content immediately.
      # ".gradle/gradle.properties".text = ''
      #   org.gradle.console=verbose
      #   org.gradle.daemon.idletimeout=3600000
      # '';
    };

    # Home Manager can also manage your environment variables through
    # 'home.sessionVariables'. These will be explicitly sourced when using a
    # shell provided by Home Manager. If you don't want to manage your shell
    # through Home Manager then you have to manually source 'hm-session-vars.sh'
    # located at either
    #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
    # or
    #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
    # or
    #  /etc/profiles/per-user/emmi/etc/profile.d/hm-session-vars.sh
    sessionVariables = {
      EDITOR = "nvim";
      SUDO_EDITOR = "nvim";
    };
  };
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
