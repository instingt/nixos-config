# User configuration - single source of truth
# This file defines all users and their profiles
#
# To add a new user:
#   1. Add a new entry in the `users` attribute set
#   2. Define packages (list of profile names from home/profiles/)
#   3. Define desktop (desktop environment name or null for servers)
#   4. Optionally add hostOverrides for host-specific configurations
#
# Example:
#   newuser = {
#     extraGroups = [ "wheel" ];
#     shell = pkgs.bash;
#     packages = [ "cli" "dev" ];
#     desktop = "gnome";
#     hostOverrides = {
#       server = { desktop = null; packages = [ "cli" ]; };
#     };
#   };
{ pkgs, ... }:
{
  users = {
    vita = {
      description = "Vita's user account";
      extraGroups = [
        "wheel"
        "networkmanager"
        "docker"
      ];
      shell = pkgs.fish;

      # Git configuration (user-specific)
      git = {
        name = "Vitaliy Kataev";
        email = "vita@kataev.pro";
        signingKey = "6664158A96D5F5D9DB8CD5DDBB28505EC0F75404";
      };

      # Default profile (used if host not in hostOverrides)
      packages = [
        "cli"
        "dev"
      ];
      desktop = "hyprland";

      # Host-specific overrides
      # Example: server host would have:
      # server = {
      #   packages = [ "cli" ];
      #   desktop = null;  # No desktop on server
      # };
    };
  };
}
