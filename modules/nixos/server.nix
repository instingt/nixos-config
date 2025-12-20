# Server module - disables graphics and enables server optimizations
# Only applies if all users have desktop = null
{
  config,
  lib,
  pkgs,
  ...
}:
let
  userConfig = import ../../lib/users.nix { inherit pkgs; };
  inherit (config.networking) hostName;

  # Check if this is a server (no users have desktop)
  isServer = lib.all (
    username:
    let
      base = userConfig.users.${username};
      override = base.hostOverrides.${hostName} or { };
      cfg = base // override;
    in
    cfg.desktop == null
  ) (builtins.attrNames userConfig.users);
in
lib.mkIf isServer {
  # Disable graphics-related services
  services.displayManager.enable = false;
  services.xserver.enable = false;

  # Server-specific optimizations can be added here
  # For example:
  # - Disable unnecessary services
  # - Enable server-specific services
  # - Optimize for headless operation
}
