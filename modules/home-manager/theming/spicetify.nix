# Spotify, themed by kurashi. kurashi's spicetify target writes the colours to ~/.config/spicetify/Themes/Kurashi/color.ini
# and runs nothing else: Spotify takes them on `spicetify apply`. That needs a writable Spotify, the store copy is read-only,
# so the `spotify` on PATH is this launcher, which keeps a patched copy in ~/.local/share/spicetify/spotify. On each start
# (while Spotify is closed; a running client is never patched) it:
#   1. copies Spotify again when the store path changed (an update), then `spicetify backup apply` on the fresh copy;
#   2. sets spicetify's config to that copy and the Kurashi theme, and takes the theme's user.css from spicetify-themes'
#      "text" theme (kurashi writes only color.ini);
#   3. otherwise runs `spicetify apply`, so the colours kurashi wrote show on this start.
# Extensions: the old build's list, copied into ~/.config/spicetify/Extensions on each start and set as `extensions`.
# A failure starts Spotify unthemed; the log is ~/.local/state/spotify-kurashi.log.
{
  pkgs,
  inputs,
  lib,
  ...
}: let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
  # spicetify-nix's extension files, the list the old config enabled. Each is {src, name}: copied into Extensions/ at start.
  extensions = map (n: spicePkgs.extensions.${n}) [
    "adblockify"
    "hidePodcasts"
    "shuffle"
    "keyboardShortcut"
    "popupLyrics"
    "beautifulLyrics"
    "queueTime"
    "history"
    "songStats"
    "featureShuffle"
    "phraseToPlaylist"
    "skipStats"
    "fullAppDisplay"
  ];
  stockSpotify = pkgs.spotify;
  spicetify = "${pkgs.spicetify-cli}/bin/spicetify";

  # spicetify-themes at the revision spicetify-nix pins (its npins hash): the "text" theme's user.css holds the CSS
  officialThemes = pkgs.fetchzip {
    url = "https://github.com/spicetify/spicetify-themes/archive/c432012478e1f2e2ffccca8e943e188af40d6190.tar.gz";
    hash = "sha256-T5S7IF/YKhrCc3EFxTjwbiNVOJjZmL+Nis6u7g33syk=";
  };

  # The stock wrapper sets the environment the binary needs (GIO modules, LD_LIBRARY_PATH, zenity); only the binary's path changes
  wrapper = pkgs.runCommand "spotify-kurashi-wrapper" {} ''
    substitute ${stockSpotify}/bin/spotify $out \
      --replace-fail '${stockSpotify}/share/spotify/.spotify-wrapped' '$SPOTIFY_COPY/.spotify-wrapped'
    chmod +x $out
  '';

  launcher = pkgs.writeShellScript "spotify" ''
    state="''${XDG_STATE_HOME:-$HOME/.local/state}"
    copy="''${XDG_DATA_HOME:-$HOME/.local/share}/spicetify/spotify"
    theme="$HOME/.config/spicetify/Themes/Kurashi"
    log="$state/spotify-kurashi.log"
    mkdir -p "$state"

    # any Spotify, the stock one included: Spotify is single-instance, so a new start only hands off to the running window
    running() {
      for exe in /proc/[0-9]*/exe; do
        case "$(readlink "$exe" 2>/dev/null)" in
          */share/spotify/.spotify-wrapped) return 0 ;;
        esac
      done
      return 1
    }

    fresh=0
    prepare_copy() {
      if [ "$(cat "$copy/.store-path" 2>/dev/null)" != "${stockSpotify}" ]; then
        rm -rf "$copy" "$HOME/.local/state/spicetify/Backup"
        mkdir -p "$(dirname "$copy")"
        cp -r ${stockSpotify}/share/spotify "$copy"
        chmod -R u+w "$copy"
        echo "${stockSpotify}" > "$copy/.store-path"
        fresh=1
      fi
    }

    apply_theme() {
      mkdir -p "$theme"
      [ -e "$theme/color.ini" ] || install -m644 ${officialThemes}/text/color.ini "$theme/color.ini"
      install -m644 ${officialThemes}/text/user.css "$theme/user.css"
      mkdir -p "$HOME/.config/spicetify/Extensions"
      ${lib.concatMapStrings (e: "install -m644 ${e.src}/${e.name} \"$HOME/.config/spicetify/Extensions/${e.name}\"\n") extensions}
      ${spicetify} config spotify_path "$copy/" current_theme Kurashi color_scheme Kurashi prefs_path "$HOME/.config/spotify/prefs" extensions "${lib.concatMapStringsSep "|" (e: e.name) extensions}" || return 1
      # the copy's own `spotify` script (what spicetify runs to restart Spotify) still names the stock binary: point it at the copy
      sed -i "s|${stockSpotify}/share/spotify/.spotify-wrapped|$copy/.spotify-wrapped|g" "$copy/spotify" || return 1
      # --no-restart: the launcher starts Spotify itself, after the apply
      if [ "$fresh" = 1 ]; then
        ${spicetify} backup apply --no-restart || return 1
      else
        ${spicetify} apply --no-restart || return 1
      fi
    }

    if running; then
      echo "spotify: Spotify is already running; quit it fully to start with the kurashi theme" | tee -a "$log" >&2
    else
      # on failure the store-path stamp goes, so the next start copies and backs up again
      { prepare_copy && apply_theme; } >>"$log" 2>&1 || {
        rm -f "$copy/.store-path"
        echo "spotify: theming failed, starting unthemed (log: $log)" >&2
      }
    fi
    export SPOTIFY_COPY="$copy"
    exec ${wrapper} "$@"
  '';

  # the launcher replaces the stock bin/spotify; the stock desktop entry and icons stay. symlinkJoin links with lndir, which
  # keeps the first path's file on a collision, so the launcher goes first
  launcherPkg = pkgs.runCommand "spotify-kurashi" {} ''
    mkdir -p $out/bin
    ln -s ${launcher} $out/bin/spotify
  '';
  spotify = pkgs.symlinkJoin {
    name = "spotify";
    paths = [launcherPkg stockSpotify];
  };
in {
  environment.systemPackages = [spotify pkgs.spicetify-cli];
}
# The previous setup, commented out. spicetify-nix built this theme into Spotify at build time (defaultDynamic: colours from
# album art), so kurashi's color.ini never reached it. Its extension list is carried over to `extensions` above.
#
# programs.spicetify = {
#   enable = true;
#   # theme = spicePkgs.themes.catppuccin;
#   # theme = spicePkgs.themes.text;
#   # theme = spicePkgs.themes.TokyoNight;
#   theme = spicePkgs.themes.defaultDynamic;
#
#   enabledExtensions = with spicePkgs.extensions; [
#     adblockify
#     hidePodcasts
#     shuffle
#     keyboardShortcut
#     popupLyrics
#     beautifulLyrics
#     # simpleBeautifulLyrics
#     queueTime
#     history
#     songStats
#     featureShuffle
#     phraseToPlaylist
#     skipStats
#     fullAppDisplay
#   ];
#   # Theme for dynamic
#   colorScheme = "Dark-Base";
# };

