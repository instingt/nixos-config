{ ... }:
{
  # Make `xdg-open` / portals pick consistent default apps.
  #
  # NOTE: `home/features/desktop/common/firefox.nix` already sets a few
  # `xdg.mimeApps.defaultApplications` entries; enabling mimeApps here activates
  # those as well.
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      # File manager
      "inode/directory" = [ "thunar.desktop" ];

      # PDF
      "application/pdf" = [ "org.gnome.Evince.desktop" ];

      # Images
      "image/jpeg" = [ "org.gnome.eog.desktop" ];
      "image/jpg" = [ "org.gnome.eog.desktop" ];
      "image/png" = [ "org.gnome.eog.desktop" ];
      "image/gif" = [ "org.gnome.eog.desktop" ];
      "image/webp" = [ "org.gnome.eog.desktop" ];
      "image/tiff" = [ "org.gnome.eog.desktop" ];
      "image/bmp" = [ "org.gnome.eog.desktop" ];
      "image/svg+xml" = [ "org.gnome.eog.desktop" ];

      # Video
      "video/mp4" = [ "io.github.celluloid_player.Celluloid.desktop" ];
      "video/x-matroska" = [ "io.github.celluloid_player.Celluloid.desktop" ];
      "video/webm" = [ "io.github.celluloid_player.Celluloid.desktop" ];
      "video/quicktime" = [ "io.github.celluloid_player.Celluloid.desktop" ];
      "video/x-msvideo" = [ "io.github.celluloid_player.Celluloid.desktop" ];
      "video/mpeg" = [ "io.github.celluloid_player.Celluloid.desktop" ];

      # Audio
      "audio/mpeg" = [ "io.github.celluloid_player.Celluloid.desktop" ];
      "audio/flac" = [ "io.github.celluloid_player.Celluloid.desktop" ];
      "audio/ogg" = [ "io.github.celluloid_player.Celluloid.desktop" ];
      "audio/opus" = [ "io.github.celluloid_player.Celluloid.desktop" ];
      "audio/wav" = [ "io.github.celluloid_player.Celluloid.desktop" ];
      "audio/x-wav" = [ "io.github.celluloid_player.Celluloid.desktop" ];
      "audio/mp4" = [ "io.github.celluloid_player.Celluloid.desktop" ];

      # Telegram deep links
      "x-scheme-handler/tg" = [ "org.telegram.desktop.desktop" ];
    };
  };
}


