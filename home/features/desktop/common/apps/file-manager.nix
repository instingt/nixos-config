{ pkgs, ... }:
{
  # Thunar + the usual integration bits for a full file-manager experience.
  home.packages = with pkgs; [
    xfce.thunar

    # Mount integration for removable drives + network locations.
    gvfs

    # Thumbnails (images + video).
    xfce.tumbler
    ffmpegthumbnailer

    # Archive handling from Thunar context menu.
    file-roller
    xfce.thunar-archive-plugin
  ];
}
