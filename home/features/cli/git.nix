# Git configuration
# Uses user-specific git config from lib/users.nix via _module.args.userGitConfig
# Configure git settings per-user in lib/users.nix:
#   git = {
#     name = "Your Name";
#     email = "your.email@example.com";
#     signingKey = "YOUR_GPG_KEY_ID";  # Optional - if provided, commits will be signed by default
#   };
{ config, lib, ... }:
let
  # Get user git config passed via _module.args
  gitConfig = config._module.args.userGitConfig or null;
  hasSigningKey = gitConfig != null && gitConfig.signingKey != null;
in
{
  programs.git = {
    enable = true;

    settings = lib.mkMerge [
      # Common git settings for all users
      {
        init.defaultBranch = "main";
      }
      # User-specific settings (if configured in lib/users.nix)
      (lib.mkIf (gitConfig != null) {
        user.name = gitConfig.name;
        user.email = gitConfig.email;
      })
      # GPG signing configuration (if signingKey is provided)
      (lib.mkIf hasSigningKey {
        user.signingKey = gitConfig.signingKey;
        commit.gpgsign = true;
      })
    ];
  };
}
