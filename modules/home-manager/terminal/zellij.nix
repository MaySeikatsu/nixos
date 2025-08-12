{ pkgs, ... }: {
  home.file.".config/zellij/config.kdl".source =
    ../../../ressources/dots/zellij/config.kdl;

  programs.zellij = {
    enable = true;
    # enableZshIntegration = true;
    # enableFishIntegration = true;
    # exitShellOnExit = true; # not working yet

    # settings = {
    # simplified_ui = false;
    # pane_frames = false;
    # ui = { pane_frames = { hide_seession_name = true; }; };
    # };
  };
}

# settings = {
#       show_startup_tips = false;
#       copy_on_select = true;
#       theme = "dracula";
#       # themes.custom.fg = "#ffffff";
#       # themes.custom.bg = "#000000";
#       # default_layout = "compact";
#       # simplified_ui = false;
#       # pane_frames = false;
#       ui.pane_frames.hide_seession_name = true;
#
#       attachExistingSession = true;
#       exitShellOnExit = true;
#
#       default_mode = "locked";
#       keybinds = {
#         _props.clear-defaults = true;
#
#         locked._children = [{
#           bind = {
#             _args = [ "Ctrl g" ];
#             _children = [{ SwitchToMode._args = [ "normal" ]; }];
#           };
#         }];
#
#         pane._children = [
#           {
#             bind = {
#               _args = [ "left" ];
#               MoveFocus = [ "left" ];
#             };
#           }
#           {
#             bind = {
#               _args = [ "down" ];
#               MoveFocus = [ "down" ];
#             };
#           }
#           {
#             bind = {
#               _args = [ "up" ];
#               MoveFocus = [ "up" ];
#             };
#           }
#           {
#             bind = {
#               _args = [ "right" ];
#               MoveFocus = [ "right" ];
#             };
#           }
#           {
#             bind = {
#               _args = [ "c" ];
#               _children = [
#                 { SwitchToMode._args = [ "renamepane" ]; }
#                 { PaneNameInput._args = [ 0 ]; }
#               ];
#             };
#           }
#           {
#             bind = {
#               _args = [ "d" ];
#               _children = [
#                 { NewPane._args = [ "down" ]; }
#                 { SwitchToMode._args = [ "normal" ]; }
#               ];
#             };
#           }
#           {
#             bind = {
#               _args = [ "e" ];
#               _children = [
#                 { TogglePaneEmbedOrFloating = { }; }
#                 { SwitchToMode._args = [ "normal" ]; }
#               ];
#             };
#           }
#           {
#             bind = {
#               _args = [ "f" ];
#               _children = [
#                 { ToggleFocusFullscreen = { }; }
#                 { SwitchToMode._args = [ "normal" ]; }
#               ];
#             };
#           }
#           {
#             bind = {
#               _args = [ "h" ];
#               MoveFocus = [ "left" ];
#             };
#           }
#           {
#             bind = {
#               _args = [ "i" ];
#               _children = [
#                 { TogglePanePinned = { }; }
#                 { SwitchToMode._args = [ "normal" ]; }
#               ];
#             };
#           }
#           {
#             bind = {
#               _args = [ "j" ];
#               MoveFocus = [ "down" ];
#             };
#           }
#           {
#             bind = {
#               _args = [ "k" ];
#               MoveFocus = [ "up" ];
#             };
#           }
#           {
#             bind = {
#               _args = [ "l" ];
#               MoveFocus = [ "right" ];
#             };
#           }
#           {
#             bind = {
#               _args = [ "n" ];
#               _children =
#                 [ { NewPane = { }; } { SwitchToMode._args = [ "normal" ]; } ];
#             };
#           }
#           {
#             bind = {
#               _args = [ "p" ];
#               SwitchFocus = { };
#             };
#           }
#           {
#             bind = {
#               _args = [ "Ctrl p" ];
#               SwitchToMode._args = [ "normal" ];
#             };
#           }
#           {
#             bind = {
#               _args = [ "r" ];
#               _children = [
#                 { NewPane._args = [ "right" ]; }
#                 { SwitchToMode._args = [ "normal" ]; }
#               ];
#             };
#           }
#           {
#             bind = {
#               _args = [ "w" ];
#               _children = [
#                 { ToggleFloatingPanes = { }; }
#                 { SwitchToMode._args = [ "normal" ]; }
#               ];
#             };
#           }
#           {
#             bind = {
#               _args = [ "z" ];
#               _children = [
#                 { TogglePaneFrames = { }; }
#                 { SwitchToMode._args = [ "normal" ]; }
#               ];
#             };
#           }
#         ];
#
#         # --- Tab Mode ---
#         tab._children = [
#           {
#             bind = {
#               _args = [ "left" ];
#               GoToPreviousTab = { };
#             };
#           }
#           {
#             bind = {
#               _args = [ "down" ];
#               GoToNextTab = { };
#             };
#           }
#           {
#             bind = {
#               _args = [ "up" ];
#               GoToPreviousTab = { };
#             };
#           }
#           {
#             bind = {
#               _args = [ "right" ];
#               GoToNextTab = { };
#             };
#           }
#           {
#             bind = {
#               _args = [ "1" ];
#               _children = [
#                 { GoToTab._args = [ 1 ]; }
#                 { SwitchToMode._args = [ "normal" ]; }
#               ];
#             };
#           }
#           {
#             bind = {
#               _args = [ "2" ];
#               _children = [
#                 { GoToTab._args = [ 2 ]; }
#                 { SwitchToMode._args = [ "normal" ]; }
#               ];
#             };
#           }
#           {
#             bind = {
#               _args = [ "3" ];
#               _children = [
#                 { GoToTab._args = [ 3 ]; }
#                 { SwitchToMode._args = [ "normal" ]; }
#               ];
#             };
#           }
#           {
#             bind = {
#               _args = [ "4" ];
#               _children = [
#                 { GoToTab._args = [ 4 ]; }
#                 { SwitchToMode._args = [ "normal" ]; }
#               ];
#             };
#           }
#           {
#             bind = {
#               _args = [ "5" ];
#               _children = [
#                 { GoToTab._args = [ 5 ]; }
#                 { SwitchToMode._args = [ "normal" ]; }
#               ];
#             };
#           }
#           {
#             bind = {
#               _args = [ "6" ];
#               _children = [
#                 { GoToTab._args = [ 6 ]; }
#                 { SwitchToMode._args = [ "normal" ]; }
#               ];
#             };
#           }
#           {
#             bind = {
#               _args = [ "7" ];
#               _children = [
#                 { GoToTab._args = [ 7 ]; }
#                 { SwitchToMode._args = [ "normal" ]; }
#               ];
#             };
#           }
#           {
#             bind = {
#               _args = [ "8" ];
#               _children = [
#                 { GoToTab._args = [ 8 ]; }
#                 { SwitchToMode._args = [ "normal" ]; }
#               ];
#             };
#           }
#           {
#             bind = {
#               _args = [ "9" ];
#               _children = [
#                 { GoToTab._args = [ 9 ]; }
#                 { SwitchToMode._args = [ "normal" ]; }
#               ];
#             };
#           }
#           {
#             bind = {
#               _args = [ "[" ];
#               _children = [
#                 { BreakPaneLeft = { }; }
#                 { SwitchToMode._args = [ "normal" ]; }
#               ];
#             };
#           }
#           {
#             bind = {
#               _args = [ "]" ];
#               _children = [
#                 { BreakPaneRight = { }; }
#                 { SwitchToMode._args = [ "normal" ]; }
#               ];
#             };
#           }
#           {
#             bind = {
#               _args = [ "b" ];
#               _children =
#                 [ { BreakPane = { }; } { SwitchToMode._args = [ "normal" ]; } ];
#             };
#           }
#           {
#             bind = {
#               _args = [ "h" ];
#               GoToPreviousTab = { };
#             };
#           }
#           {
#             bind = {
#               _args = [ "j" ];
#               GoToNextTab = { };
#             };
#           }
#           {
#             bind = {
#               _args = [ "k" ];
#               GoToPreviousTab = { };
#             };
#           }
#           {
#             bind = {
#               _args = [ "l" ];
#               GoToNextTab = { };
#             };
#           }
#           {
#             bind = {
#               _args = [ "n" ];
#               _children =
#                 [ { NewTab = { }; } { SwitchToMode._args = [ "normal" ]; } ];
#             };
#           }
#           {
#             bind = {
#               _args = [ "r" ];
#               _children = [
#                 { SwitchToMode._args = [ "renametab" ]; }
#                 { TabNameInput._args = [ 0 ]; }
#               ];
#             };
#           }
#           {
#             bind = {
#               _args = [ "s" ];
#               _children = [
#                 { ToggleActiveSyncTab = { }; }
#                 { SwitchToMode._args = [ "normal" ]; }
#               ];
#             };
#           }
#           {
#             bind = {
#               _args = [ "Ctrl t" ];
#               SwitchToMode._args = [ "normal" ];
#             };
#           }
#           {
#             bind = {
#               _args = [ "x" ];
#               _children =
#                 [ { CloseTab = { }; } { SwitchToMode._args = [ "normal" ]; } ];
#             };
#           }
#           {
#             bind = {
#               _args = [ "tab" ];
#               ToggleTab = { };
#             };
#           }
#         ];
#
#         # (...) Define other groups here like resize, move, scroll, search, session,
#         # and all `shared_except`/`shared_among` sections the same way.
#       };
#     };
