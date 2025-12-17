{
  config,
  lib,
  pkgs,
  ...
}:
{
  users.users.greeter = {
    extraGroups = [ "seat" ];
  };
  services = {
    seatd.enable = true;
    greetd = {
      enable = true;
      # If regreet is enabled, let its module configure greetd.
      settings = lib.mkIf (!config.programs.regreet.enable) {
        default_session.command = "${pkgs.greetd}/bin/agreety --cmd $SHELL";
      };
    };
    displayManager = {
      enable = true;
      # Export user sessions to system
      sessionPackages = lib.flatten (
        lib.mapAttrsToList (_: v: v.home.exportedSessionPackages) config.home-manager.users
      );
    };
  };
}
