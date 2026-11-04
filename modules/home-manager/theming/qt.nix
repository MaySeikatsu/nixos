# Qt apps read qt6ct (QT_QPA_PLATFORMTHEME, set for niri's apps in ressources/dots/niri/config.kdl). The style and the
# palette follow the theming switch (theming/kurashi.nix): off = Kvantum's rose-pine-moon-iris, on = kurashi's colours
# (qt6ct's colors/kurashi.conf, written by kurashi's qt target) in Fusion. The icon theme is rose-pine-moon either way.
# Fonts stay as they were: kurashi does not write them into qt6ct.
{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}: let
  on = lib.attrByPath ["my" "kurashi-theming" "enable"] false osConfig;
  appearance = lib.concatStringsSep "\n" (
    ["[Appearance]"]
    ++ lib.optional on "color_scheme_path=${config.xdg.configHome}/qt6ct/colors/kurashi.conf"
    ++ [
      "custom_palette=${lib.boolToString on}"
      "icon_theme=rose-pine-moon"
      "standard_dialogs=default"
      "style=${
        if on
        then "Fusion"
        else "kvantum"
      }"
    ]
  );
in {
  qt = {
    enable = true;
  };

  # The Qt platform theme of every session, so apps launched outside niri (kurashi's launcher, user services) get qt6ct
  # too. Niri's own children get the same from its environment block (ressources/dots/niri/config.kdl).
  systemd.user.sessionVariables.QT_QPA_PLATFORMTHEME = "qt6ct";

  home.file = {
    ".config/qt6ct/qt6ct.conf" = {
      force = true;
      text = ''
        ${appearance}

        [Fonts]
        fixed="Monospace,12,-1,5,400,0,0,0,0,0,0,0,0,0,0,1,,0,0"
        general="Sans Serif,12,-1,5,400,0,0,0,0,0,0,0,0,0,0,1,,0,0"

        [Interface]
        activate_item_on_single_click=1
        buttonbox_layout=3
        cursor_flash_time=1000
        dialog_buttons_have_icons=1
        double_click_interval=400
        gui_effects=@Invalid()
        keyboard_scheme=2
        menus_have_icons=true
        show_shortcuts_in_context_menus=true
        stylesheets=@Invalid()
        toolbutton_style=4
        underline_shortcut=1
        wheel_scroll_lines=3

        [SettingsWindow]
        geometry=@ByteArray(\x1\xd9\xd0\xcb\0\x3\0\0\0\0\0\0\0\0\0\0\0\0\x4\xe6\0\0\x5w\0\0\0\0\0\0\0\0\0\0\x4\xe6\0\0\x5w\0\0\0\0\0\0\0\0\n\0\0\0\0\0\0\0\0\0\0\0\x4\xe6\0\0\x5w)

        [Troubleshooting]
        force_raster_widgets=1
        ignored_applications=@Invalid()
      '';
    };
    ".config/Kvantum/rose-pine-moon-iris".source = "${pkgs.rose-pine-kvantum}/share/Kvantum/themes/rose-pine-moon-iris";
    ".config/Kvantum/kvantum.kvconfig".text = ''
      [General]
      theme=rose-pine-moon-iris
    '';
  };
}
