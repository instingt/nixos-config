# Desktop module - enables graphics stack
# Import this module if you have users with desktop environments
# The display manager will automatically detect exported session packages from home-manager
{
  # Import display manager configuration
  # Note: This import path is resolved relative to this module file
  # Since this module is at modules/nixos/desktop.nix,
  # we need to go up to root, then into hosts
  imports = [
    ../../hosts/common/global/display-manager.nix
  ];

  # Required for Home Manager GTK/cursor theming (dconf DBus service: ca.desrt.dconf)
  programs.dconf.enable = true;
  services = {

    # Desktop plumbing for file managers and portals:
    # - GVFS provides network locations (smb/sftp/etc) and trash:// integration.
    # - UDisks2 provides mount support for removable drives (via polkit).
    gvfs.enable = true;
    udisks2.enable = true;

    # Optional but useful for "Browse Network" / device discovery on LAN.
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };
}
