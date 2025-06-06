{ config, inputs, pkgs, system, ... }:
{
  imports = [
    ./../modules/home-manager/hyprland/default.nix
    ./../modules/home-manager/hyprland_utils/default.nix

    ./../modules/home-manager/terminal/zsh.nix
    ./../modules/home-manager/terminal/tmux.nix
    ./../modules/home-manager/zen-browser.nix
    ./../modules/home-manager/nixcord.nix
    ./../modules/home-manager/ghostty.nix
    ./../modules/home-manager/terminal/git.nix
    ./../modules/home-manager/terminal/yazi.nix
    ../modules/home-manager/hyprland_utils/stylix.nix
    ../modules/home-manager/cava.nix
    ../modules/home-manager/kitty.nix
    ../modules/home-manager/alacritty.nix
    ../modules/home-manager/btop.nix
    ../modules/home-manager/fzf.nix
    ../modules/home-manager/lazygit.nix
    ../modules/home-manager/rofi.nix
    ../modules/home-manager/wofi.nix
    ../modules/home-manager/wezterm.nix
    ../modules/home-manager/gtk.nix
    ../modules/home-manager/qt.nix
    # ../modules/home-manager/neovim.nix
    ../modules/home-manager/niri/default.nix
    ../modules/home-manager/hyprland_utils/wallust.nix
    
    # ../modules/home-manager/textfox.nix
    # ./../modules/home-manager/matugen.nix
    # ./../../modules/home-manager/kanata.nix
    # ./../../modules/home-manager/rofi/default.nix
    # ./../../modules/home-manager/neovim.nix
    # ./../../modules/home-manager/starship.nix
    # ./../../modules/home-manager/tidal.nix
    # inputs.stylix.homeModules.stylix
  ];

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "maike";
  home.homeDirectory = "/home/maike";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.

# systemd.user.services.hellwal-update = {
#   Unit = {
#     Description = "Update Ghostty color scheme with hellwal";
#     After = [ "graphical-session.target" ];
#   };
#   Service = {
#     Type = "oneshot";
#     ExecStart = "${pkgs.hellwal}/bin/hellwal --wallpaper "${config.stylix.image}";
#   };
#   Install = {
#     WantedBy = [ "default.target" ];
#   };
# };
#
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.11"; # Please read the comment before changing.
  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    pkgs.hyprpanel
    pkgs.hellwal
    
    #csharp dev env
    # pkgs.jetbrains.rider

    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # pkgs.hyprpanel
    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
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
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/emmi/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "nvim";
    SUDO_EDITOR = "nvim";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
