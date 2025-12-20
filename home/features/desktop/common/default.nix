# Common desktop features - shared across all desktop environments
# Note: wofi.nix has been moved to hyprland-specific since it's currently only used with Hyprland.
# If other Wayland compositors need wofi, it can be moved back here.
{
  imports = [
    ./kitty.nix
    ./font.nix
    ./firefox.nix
    ./theme.nix
    ./apps
  ];
}
