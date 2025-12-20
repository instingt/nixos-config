# Desktop base profile - common desktop apps and configs
# This profile provides common desktop functionality shared across all desktop environments.
# Desktop-specific configurations (like xdg.portal settings) should be in their respective profiles.
{ pkgs, ... }:
{
  imports = [
    ../../features/desktop/common
  ];

  home.packages = [
    pkgs.libnotify
    pkgs.handlr-regex
    (pkgs.writeShellScriptBin "xterm" ''
      handlr launch x-scheme-handler/terminal -- "$@"
    '')
    (pkgs.writeShellScriptBin "xdg-open" ''
      handlr open "$@"
    '')
  ];
}
