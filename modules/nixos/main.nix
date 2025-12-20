# Main NixOS module - automatically imported for all hosts
# Conditionally enables users, desktop, and server modules based on user configuration
{
  config,
  lib,
  pkgs,
  ...
}:
let
  userConfig = import ../../lib/users.nix { inherit pkgs; };
  inherit (config.networking) hostName;

  # Check if any user has a desktop environment
  hasDesktop = lib.any (
    username:
    let
      base = userConfig.users.${username};
      override = base.hostOverrides.${hostName} or { };
      cfg = base // override;
    in
    cfg.desktop != null
  ) (builtins.attrNames userConfig.users);

  # Check if this is a server (all users have desktop = null)
  isServer = lib.all (
    username:
    let
      base = userConfig.users.${username};
      override = base.hostOverrides.${hostName} or { };
      cfg = base // override;
    in
    cfg.desktop == null
  ) (builtins.attrNames userConfig.users);

  # Build imports list conditionally
  conditionalImports =
    [ ]
    ++ [ ./users.nix ] # Always import users module
    ++ lib.optionals hasDesktop [ ./desktop.nix ] # Only if users have desktop
    ++ lib.optionals isServer [ ./server.nix ]; # Only if all users have desktop = null
in
{
  imports = conditionalImports;
}
