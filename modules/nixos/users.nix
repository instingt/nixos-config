# User management module
# Generates user accounts and home-manager configurations from lib/users.nix
{
  config,
  lib,
  pkgs,
  ...
}:
let
  userConfig = import ../../lib/users.nix { inherit pkgs; };

  # Generate user account and home-manager config
  mkUser = username: cfg: {
    users.users.${username} = {
      isNormalUser = true;
      inherit (cfg) extraGroups shell;
      description = cfg.description or "";
      hashedPasswordFile = config.sops.secrets."${username}-password".path;
    };

    sops.secrets."${username}-password" = {
      sopsFile = ../../hosts/common/secrets.yaml;
      neededForUsers = true;
    };

    # Home Manager configuration
    home-manager.users.${username} = {
      imports = [
        ../../home/profiles/base.nix
      ]
      # Add package profiles
      ++ map (pkg: ../../home/profiles/${pkg}.nix) cfg.packages
      # Add desktop profile if desktop is set
      ++ lib.optionals (cfg.desktop != null) [
        ../../home/profiles/desktop/base.nix
        ../../home/profiles/desktop/${cfg.desktop}.nix
      ];
      # Note: User-specific overrides can be added by creating home/users/${username}.nix
      # and importing it manually in the host configuration if needed

      home = {
        inherit username;
        homeDirectory = "/home/${username}";
        stateVersion = "25.11";
      };

      # Pass user-specific git config via extraSpecialArgs
      _module.args = {
        userGitConfig = cfg.git or null;
      };
    };
  };
in
{
  # Generate all users for this host
  imports = lib.mapAttrsToList mkUser userConfig.users;
}
