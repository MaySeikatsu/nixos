{...}:
{
  wayland.windowManager.hyprland.settings = {

    "$mainMod" = "Super";
    bind = [
      # Window/Session actions
      "$mainMod, Q, killactive,"
      "Alt, F4, killactive,"
      "$mainMod, Delete, exit,"
      "$mainMod, W, togglefloating,"
      "$mainMod, G, togglegroup,"
      "Alt, Return, fullscreen,"
      # $mainMod, Escape, exec, swaylock # launch lock screen
      "$mainMod, Escape, exec, hyprlock"
      "$mainMod+Shift, F, exec, $scrPath/windowpin.sh"
      "$mainMod, Backspace, exec, $scrPath/logoutlaunch.sh"
      "Ctrl+Alt, W, exec, killall waybar || waybar"
      "$mainMod, Esc, exit,"

      # Application shortcuts
      "$mainMod, T, exec, $term"
      "$mainMod, E, exec, $file"
      "$mainMod, N, exec, $editor"
      "$mainMod, B, exec, $browser1"
      "$mainMod+Shift, B, exec, $browser1-work"
      "$mainMod, M, exec, $teams" 
      "$mainMod, D, exec, $discord"
      "$mainMod, Y, exec, $browser2"
      "$mainMod, C, exec, $vscode"
      "$mainMod, D, exec, $discord"
      "$mainMod+Shift, D, exec, $discord-pwa"

      "Ctrl+Shift, Escape, exec, $scrPath/sysmonlaunch.sh"
      # Rofi menus
      "$mainMod, A, exec, rofi -show drun"
      "Alt, Space, exec, rofi -show drun"
      # Alt, Space, exec, pkill -x rofi #|| $scrPath/rofilaunch.sh d # launch application launcher
      "$mainMod, Tab, exec, pkill -x rofi || $scrPath/rofilaunch.sh w"
      "$mainMod+Shift, E, exec, pkill -x rofi || $scrPath/rofilaunch.sh f"
      "$mainMod CTRL , S, changegroupactive, b" 
      "$mainMod CTRL , D, changegroupactive, f" 

      # Screenshot/Screencapture
      "$mainMod, P, exec, hyprshot -m region output --clipboard-only --freeze" # partial screenshot capture       
      "$mainMod+Shift, S, exec, hyprshot -m region output --clipboard-only --freeze" # partial screenshot capture 
      "$mainMod+Ctrl, P, exec, $scrPath/screenshot.sh sf" # partial screenshot capture (frozen screen)           
      "$mainMod+Alt, P, exec, $scrPath/screenshot.sh m" # monitor screenshot capture                             
      ", Print, exec, $scrPath/screenshot.sh p" # all monitors screenshot capture                                

      # Move/Change window focus
      "$mainMod, Left, movefocus, l"  
      "$mainMod, Right, movefocus, r" 
      "$mainMod, Up, movefocus, u"    
      "$mainMod, Down, movefocus, d"  
      "Alt, Tab, movefocus, d"        
                                    
      "$mainMod, H, movefocus, l"     
      "$mainMod, L, movefocus, r"     
      "$mainMod, K, movefocus, u"     
      "$mainMod, J, movefocus, d"     
      "Alt, Tab, movefocus, d"        

      # Switch workspaces
      "$mainMod, 1, workspace, 1"
      "$mainMod, 2, workspace, 2"
      "$mainMod, 3, workspace, 3"
      "$mainMod, 4, workspace, 4"
      "$mainMod, 5, workspace, 5"
      "$mainMod, 6, workspace, 6"
      "$mainMod, 7, workspace, 7"
      "$mainMod, 8, workspace, 8"
      "$mainMod, 9, workspace, 9"
      "$mainMod, 0, workspace, 10"

      # Switch workspaces to a relative workspace
      "$mainMod+Ctrl, Down, workspace, r+1" #Vertical Workspaces
      "$mainMod+Ctrl, Up, workspace, r-1"
      "$mainMod+Ctrl, Right, workspace, r+1" #Horizontal Workspaces
      "$mainMod+Ctrl, Left, workspace, r-1"

      "$mainMod+Ctrl, j, workspace, r+1" #Vertical Workspaces
      "$mainMod+Ctrl, k, workspace, r-1"
      "$mainMod+Ctrl, l, workspace, r+1" #Horizontal Workspaces
      "$mainMod+Ctrl, h, workspace, r-1"

      # Move to the first empty workspace
      # "$mainMod+Ctrl, Right, workspace, empty" 
      
      # Scroll through existing workspaces
      "$mainMod, mouse_down, workspace, e+1"
      "$mainMod, mouse_up, workspace, e-1"   

      # Move/Switch to special workspace (scratchpad)
      "$mainMod+Alt, S, movetoworkspacesilent, special"
      "$mainMod, S, togglespecialworkspace,"
      "$mainMod, F12, togglespecialworkspace,"

      # Toggle focused window split
      "$mainMod, slash, togglesplit"

      # Move focused window to a workspace silently
      "$mainMod+Alt, 1, movetoworkspacesilent, 1"
      "$mainMod+Alt, 2, movetoworkspacesilent, 2"
      "$mainMod+Alt, 3, movetoworkspacesilent, 3"
      "$mainMod+Alt, 4, movetoworkspacesilent, 4"
      "$mainMod+Alt, 5, movetoworkspacesilent, 5"
      "$mainMod+Alt, 6, movetoworkspacesilent, 6"
      "$mainMod+Alt, 7, movetoworkspacesilent, 7"
      "$mainMod+Alt, 8, movetoworkspacesilent, 8"
      "$mainMod+Alt, 9, movetoworkspacesilent, 9"
      "$mainMod+Alt, 0, movetoworkspacesilent, 10"

      # Move focused window to a workspace
      "$mainMod+Shift, 1, movetoworkspace, 1"
      "$mainMod+Shift, 2, movetoworkspace, 2"
      "$mainMod+Shift, 3, movetoworkspace, 3"
      "$mainMod+Shift, 4, movetoworkspace, 4"
      "$mainMod+Shift, 5, movetoworkspace, 5"
      "$mainMod+Shift, 6, movetoworkspace, 6"
      "$mainMod+Shift, 7, movetoworkspace, 7"
      "$mainMod+Shift, 8, movetoworkspace, 8"
      "$mainMod+Shift, 9, movetoworkspace, 9"
      "$mainMod+Shift, 0, movetoworkspace, 10"

      # Move focused window to a relative workspace
      # "$mainMod+Ctrl+Alt, Down, movetoworkspace, r+1"
      "$mainMod+Ctrl+Alt, j, movetoworkspace, r+1"
      "$mainMod+Ctrl+Alt, l, movetoworkspace, r+1"
      # "$mainMod+Ctrl+Alt, Up, movetoworkspace, r-1"
      "$mainMod+Ctrl+Alt, k, movetoworkspace, r-1"
      "$mainMod+Ctrl+Alt, h, movetoworkspace, r-1"

      # Move focused window to a relative workspace
      "$mainMod+Ctrl+Shift, j, movewindow, d"
      "$mainMod+Ctrl+Shift, l, movewindow, r"
      "$mainMod+Ctrl+Shift, k, movewindow, u"
      "$mainMod+Ctrl+Shift, h, movewindow, l"
      # Custom scripts
      # $mainMod+Alt, G, exec, $scrPath/gamemode.sh # disable hypr effects for gamemode
      # $mainMod+Alt, Right, exec, $scrPath/swwwallpaper.sh -n # next wallpaper
      # $mainMod+Alt, Left, exec, $scrPath/swwwallpaper.sh -p # previous wallpaper
      # $mainMod+Alt, Up, exec, $scrPath/wbarconfgen.sh n # next waybar mode
      # $mainMod+Alt, Down, exec, $scrPath/wbarconfgen.sh p # previous waybar mode
      # $mainMod+Shift, R, exec, pkill -x rofi || $scrPath/wallbashtoggle.sh -m # launch wallbash mode select menu
      # $mainMod+Shift, T, exec, pkill -x rofi || $scrPath/themeselect.sh # launch theme select menu
      # $mainMod+Shift, A, exec, pkill -x rofi || $scrPath/rofiselect.sh # launch select menu
      # $mainMod+Shift, W, exec, pkill -x rofi || $scrPath/swwwallselect.sh # launch wallpaper select menu
      # $mainMod, V, exec, pkill -x rofi || $scrPath/cliphist.sh c # launch clipboard
      # $mainMod+Shift, k, exec, $scrPath/keyboardswitch.sh # switch keyboard layout
    ];

    bindel = [
      # Laptop multimedia keys for volume and LCD brightness
      ",XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+"
      ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-"
      ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
      ",XF86MonBrightnessUp, exec, brightnessctl s 10%+"
      ",XF86MonBrightnessDown, exec, brightnessctl s 10%-"
    ];
    bindl = [
      # Requires playerctl
      ", XF86AudioNext, exec, playerctl next"
      ", XF86AudioPause, exec, playerctl play-pause"
      ", XF86AudioPlay, exec, playerctl play-pause"
      ", XF86AudioPrev, exec, playerctl previous"
    ];

    binde = [
    #Resize Windows
      "$mainMod+Shift, Right, resizeactive, 30 0"
      "$mainMod+Shift, Left, resizeactive, -30 0"
      "$mainMod+Shift, Up, resizeactive, 0 -30"  
      "$mainMod+Shift, Down, resizeactive, 0 30" 
                                              
      "$mainMod+Shift, l, resizeactive, 30 0"    
      "$mainMod+Shift, h, resizeactive, -30 0"   
      "$mainMod+Shift, k, resizeactive, 0 -30"   
      "$mainMod+Shift, j, resizeactive, 0 30"    
    ];
    bindm = [
    # Move/Resize focused window
      "$mainMod, mouse:272, movewindow"   
      "$mainMod, mouse:273, resizewindow" 
      "$mainMod, Z, movewindow"           
      "$mainMod, X, resizewindow"         
#bindm = ,mouse:274, movewindow
#bindm = ,mouse:272+mouse:273, movewindow
    ];
  };
}
