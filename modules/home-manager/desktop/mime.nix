{ ... }: {
  xdg.mimeApps = {
    enable = true;

    defaultApplications = {
      # File manager
      "inode/directory" = "org.gnome.Nautilus.desktop";

      # Images (Loupe is installed; feh is NOT installed)
      "image/jpeg"                = "org.gnome.Loupe.desktop";
      "image/png"                 = "org.gnome.Loupe.desktop";
      "image/gif"                 = "org.gnome.Loupe.desktop";
      "image/webp"                = "org.gnome.Loupe.desktop";
      "image/tiff"                = "org.gnome.Loupe.desktop";
      "image/heic"                = "org.gnome.Loupe.desktop";
      "image/avif"                = "org.gnome.Loupe.desktop";
      "image/jxl"                 = "org.gnome.Loupe.desktop";
      "image/bmp"                 = "org.gnome.Loupe.desktop";
      "image/svg+xml"             = "org.gnome.Loupe.desktop";
      "image/vnd.adobe.photoshop" = "org.kde.krita.desktop";

      # Web / browser
      "text/html"                     = "zen-twilight.desktop";
      "application/xhtml+xml"         = "zen-twilight.desktop";
      "application/x-extension-htm"   = "zen-twilight.desktop";
      "application/x-extension-html"  = "zen-twilight.desktop";
      "application/x-extension-shtml" = "zen-twilight.desktop";
      "application/x-extension-xht"   = "zen-twilight.desktop";
      "application/x-extension-xhtml" = "zen-twilight.desktop";
      "x-scheme-handler/http"         = "zen-twilight.desktop";
      "x-scheme-handler/https"        = "zen-twilight.desktop";
      "x-scheme-handler/chrome"       = "zen-twilight.desktop";
      "x-scheme-handler/about"        = "zen-twilight.desktop";
      "x-scheme-handler/ftp"          = "zen-twilight.desktop";

      # PDF and documents
      "application/pdf"      = "org.pwmt.zathura-pdf-mupdf.desktop";
      "application/epub+zip" = "org.pwmt.zathura-pdf-mupdf.desktop";

      # Office documents
      "application/msword"                                                        = "onlyoffice-desktopeditors.desktop";
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document"   = "onlyoffice-desktopeditors.desktop";
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"         = "onlyoffice-desktopeditors.desktop";
      "application/vnd.openxmlformats-officedocument.presentationml.presentation" = "onlyoffice-desktopeditors.desktop";
      "application/vnd.oasis.opendocument.text"                                   = "onlyoffice-desktopeditors.desktop";
      "application/vnd.oasis.opendocument.spreadsheet"                            = "onlyoffice-desktopeditors.desktop";

      # Video
      "video/mp4"        = "mpv.desktop";
      "video/x-matroska" = "mpv.desktop";
      "video/webm"       = "mpv.desktop";
      "video/mpeg"       = "mpv.desktop";
      "video/x-msvideo"  = "mpv.desktop";
      "video/quicktime"  = "mpv.desktop";
      "video/mp2t"       = "mpv.desktop";
      "video/x-flv"      = "mpv.desktop";
      "video/3gpp"       = "mpv.desktop";

      # Audio
      "audio/mpeg"  = "mpv.desktop";
      "audio/flac"  = "mpv.desktop";
      "audio/ogg"   = "mpv.desktop";
      "audio/x-wav" = "mpv.desktop";
      "audio/mp4"   = "mpv.desktop";
      "audio/x-m4a" = "mpv.desktop";
      "audio/opus"  = "mpv.desktop";
      "audio/aac"   = "mpv.desktop";

      # Text / code
      "text/plain"         = "org.kde.kate.desktop";
      "text/markdown"      = "org.kde.kate.desktop";
      "application/json"   = "org.kde.kate.desktop";
      "application/x-yaml" = "org.kde.kate.desktop";

      # Scheme handlers — chat
      "x-scheme-handler/discord"       = "vesktop.desktop";
      "x-scheme-handler/sgnl"          = "signal.desktop";
      "x-scheme-handler/signalcaptcha" = "signal.desktop";
      "x-scheme-handler/msteams"       = "teams-for-linux.desktop";

      # Scheme handlers — other apps
      "x-scheme-handler/spotify"  = "spotify.desktop";
      "x-scheme-handler/obsidian" = "obsidian.desktop";
    };
  };
}
