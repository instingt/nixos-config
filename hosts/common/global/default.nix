{ inputs, outputs, ... }:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ./display-manager.nix
    ./fish.nix
    ./locale.nix
    ./nix-ld.nix
    ./nix.nix
    ./openssh.nix
    ./upower.nix
    ./sops.nix
  ];

  # Required for Home Manager GTK/cursor theming (dconf DBus service: ca.desrt.dconf)
  programs.dconf.enable = true;

  # Desktop plumbing for file managers and portals:
  # - GVFS provides network locations (smb/sftp/etc) and trash:// integration.
  # - UDisks2 provides mount support for removable drives (via polkit).
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  # Optional but useful for "Browse Network" / device discovery on LAN.
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  home-manager.useGlobalPkgs = true;
  # Avoid activation failures when Home Manager starts managing a file that
  # already exists (e.g. ~/.config/mimeapps.list after enabling xdg.mimeApps).
  home-manager.backupFileExtension = "hm-bak";
  home-manager.extraSpecialArgs = {
    inherit inputs outputs;
  };
}
