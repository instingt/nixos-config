{ pkgs, ... }:
{
  # Telegram Desktop is Qt-based; include Qt GTK style plugins so it matches the
  # rest of the (GTK-themed) desktop as closely as possible.
  home.packages = with pkgs; [
    telegram-desktop

    # Qt5 "gtk2" style plugin.
    libsForQt5.qtstyleplugins

    # Qt6 "gtk2" style plugin.
    qt6Packages.qt6gtk2
  ];
}


