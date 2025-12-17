{ pkgs }:
{
  plymouth-spinner-monochrome = pkgs.callPackage ./plymouth-spinner-monochrome { };
  hyprland-session-quiet = pkgs.callPackage ./hyprland-session-quiet { };
}
