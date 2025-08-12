{ pkgs, ... }:
{
  programs.zellij = {
    enable = true;
    # enableZshIntegration = true;
    enableFishIntegration = true;

    exitShellOnExit = true;
    settings = {
      show_startup_tips = false;
      theme = "dracula";
      copy_on_select = true;
      default_mode = "locked";
    };

    #shortcut = " ";
    # settings = {
    #   theme = "dracula";
    #   # default_mode = "locked";
    #   show_startup_tips = false;
    #   keybinds = {
    #     normal = {
    #       unbind = [ "Ctrl h" ];
    #       # bind = [{
    #       #   key = "Ctrl m";
    #       #   action = ''SwitchToMode "move";'';
    #       # }];
    #     };
    #   };
    # this changed the bottom row color
    # simplified_ui = false;
    # pane_frames = false;
    # ui = { pane_frames = { hide_seession_name = true; }; };
    # };
  };
}
