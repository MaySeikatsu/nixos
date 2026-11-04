# kurashi theming: one switch decides who styles the apps. It is my.kurashi-theming.enable (modules/nixos/profiles.nix).
#
#   off  every app keeps its Nix default: rose-pine-moon where it has one, the app's own look where it has none.
#        kurashi runs the shell (desktop/kurashi.nix) and styles nothing else.
#   on   kurashi styles what it can (themeExport in desktop/kurashi.nix: niri, foot, ghostty, GTK, Qt, KDE, GNOME apps). The
#        bridge (./kurashi/bridge.py) renders the rest from kurashi's tokens. A token kurashi does not send comes from the
#        Nix palette (./kurashi/palette.nix), so that palette is both the default and the fallback.
#
# The bridge's files are Home Manager links to their Nix render while the switch is off, and the bridge writes them while
# it is on. Design notes: the Obsidian note "theming design system" (personal (main)).
{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}: let
  on = lib.attrByPath ["my" "kurashi-theming" "enable"] false osConfig;
  python = "${pkgs.python3}/bin/python3";
  bridge = ./kurashi/bridge.py;
  staticTokens = pkgs.writeText "kurashi-palette-static.json" (builtins.toJSON (import ./kurashi/palette.nix));

  # The files the bridge owns, paths relative to $HOME. To give an app its theme from kurashi, add a template and an entry.
  owned = [
    {
      name = "helix";
      template = ./kurashi/templates/helix.toml.tmpl;
      out = ".config/helix/themes/kurashi.toml";
    }
    {
      name = "helix-yazelix";
      template = ./kurashi/templates/helix.toml.tmpl;
      out = ".config/yazelix/helix/themes/kurashi.toml";
    }
    {
      name = "nvim-palette";
      template = ./kurashi/templates/nvim-palette.lua.tmpl;
      out = ".config/nvim/lua/kurashi/palette.lua";
    }
    {
      name = "fzf-fish";
      template = ./kurashi/templates/fzf.fish.tmpl;
      out = ".config/kurashi/fzf.fish";
    }
  ];

  registry = pkgs.writeText "kurashi-theme-registry.json" (builtins.toJSON {
    targets =
      map (t: {
        inherit (t) name out;
        template = "${t.template}";
      })
      owned;
  });

  # The Nix render of every owned file: what the files are while the switch is off.
  seeds = pkgs.runCommand "kurashi-theme-seeds" {} ''
    ${python} ${bridge} render --registry ${registry} --static ${staticTokens} --out $out
  '';
in {
  home.file = lib.mkMerge [
    (lib.mkIf (!on) (lib.listToAttrs (map (t:
      lib.nameValuePair t.out {
        source = "${seeds}/${t.name}";
        force = true;
      })
    owned)))
    # GTK 3 imports kurashi's colours only while the switch is on (the kurashi module adds the import to gtk.css). Off,
    # the file is empty, so an import left from an earlier run stops applying.
    (lib.mkIf (!on) {
      ".config/gtk-3.0/gtk.css" = {
        text = "";
        force = true;
      };
    })
    # neovim's rose-pine reads the palette the bridge writes (lua/kurashi/palette.lua). The live nvim config is a copy
    # of ressources/dots/nvim, so this one file is linked from the repo.
    {
      ".config/nvim/lua/plugins/rosepine.lua" = {
        source = ../../../ressources/dots/nvim/lua/plugins/rosepine.lua;
        force = true;
      };
    }
    # KDE's scheme folder gets kurashi's file: a link out of the store, since kurashid rewrites the file (see the KDE block
    # below). Off: no link.
    (lib.mkIf on {
      ".local/share/color-schemes/Kurashi.colors" = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.xdg.dataHome}/kurashi/color-schemes/Kurashi.colors";
        force = true;
      };
    })
  ];

  # GTK 4 takes the kurashi import while the switch is on (the kurashi module writes its gtk.css). The file is a symlink
  # into the system profile (adw-gtk3), which Home Manager refuses to replace unless it is forced. Set through xdg.configFile
  # so it merges with the entry the GTK module writes (a home.file key of its own would be a second entry for the same file).
  xdg.configFile."gtk-4.0/gtk.css" = lib.mkIf on {
    force = true;
  };

  # The foot template. kurashi's bundled one writes a [colors] section, which foot 1.28 rejects; kurashid reads a copy in
  # ~/.config/kurashi/templates/ in place of the bundled one. Only while the switch is on, since foot is exported only then.
  xdg.configFile."kurashi/templates/foot.ini" = lib.mkIf on {
    source = ./kurashi/templates/foot.ini;
  };

  # KDE apps (Dolphin) take their view colours from KDE's colour scheme, the one kdeglobals names. kurashid writes its scheme to
  # ~/.local/share/kurashi/color-schemes/ (kurashi's @data/ resolves there), but KDE searches ~/.local/share/color-schemes/: the
  # link for that folder is in home.file above. Here kdeglobals names the scheme. Which group KDE reads is not verified: KF6's
  # colour-scheme library carries both "General" and "UiSettings" (kurashi's own KDE lines say UiSettings), so both get the name.
  # Off: each name is cleared only where it says Kurashi, so KDE is back on its default scheme.
  home.activation.kdeColorScheme = lib.hm.dag.entryAfter ["writeBoundary"] (let
    kread = "${pkgs.kdePackages.kconfig}/bin/kreadconfig6";
    kwrite = "${pkgs.kdePackages.kconfig}/bin/kwriteconfig6";
    groups = ["General" "UiSettings"];
  in
    lib.concatMapStrings (g:
      if on
      then "run ${kwrite} --file kdeglobals --group ${g} --key ColorScheme Kurashi\n"
      else ''
        if [ "$(${kread} --file kdeglobals --group ${g} --key ColorScheme)" = Kurashi ]; then
          run ${kwrite} --file kdeglobals --group ${g} --key ColorScheme --delete
        fi
      '')
    groups);

  systemd.user.services.kurashi-theme-bridge = lib.mkIf on {
    Unit = {
      Description = "kurashi theming bridge: the apps kurashi does not style, from kurashi's theme and the Nix palette";
      PartOf = ["graphical-session.target"];
      After = ["graphical-session.target" "kurashid.service"];
      Wants = ["kurashid.service"];
    };
    Service = {
      Type = "simple";
      ExecStart = lib.concatStringsSep " " [
        python
        "${bridge}"
        "run"
        "--registry"
        "${registry}"
        "--static"
        "${staticTokens}"
        "--kurashi"
        "${config.programs.kurashi.package}/bin/kurashi"
      ];
      Restart = "on-failure";
      RestartSec = 2;
    };
    Install.WantedBy = ["graphical-session.target"];
  };
}
