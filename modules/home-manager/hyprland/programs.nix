{...}:
{

  wayland.windowManager.hyprland.settings = {
      source = "~/.config/hypr/colors-hyprland.conf";
       # we need to create this file in hyprland dir to make sure we don't get a build error on sourcing in the next line - this is now done inside of the swww script
      # "$term" = "ghostty"; 
      "$term" = "foot"; 
      # "$term" = "alacritty"; 
      "$editor" = "nvim";
      "$file" = "dolphin";
      "$browser1" = ''microsoft-edge-dev --profile-directory="Default"'';
      "$browser1-work" = ''microsoft-edge-dev --profile-directory="Profile 3"'';
      "$browser2" = "zen";#io.github.zen_browser.zen
      "$teams" = "teams";
      "$discord" = "discord";
      "$vscode" = "code";
      "$discord-pwa" = ''/opt/microsoft/msedge-dev/microsoft-edge-dev --profile-directory=Default --app-id=nebbmpibgobljecgkdipmcfonkkmcggn --app-url=https://neverdecaf.github.io/discord-PWA/index.html'';
    };
}
