{ inputs, outputs, ... }:
{
  imports = [
    # NixOS modules - automatically imported for all hosts
    # Only import the default module which conditionally includes users/desktop/server
    outputs.nixosModules.default
    # Home Manager
    inputs.home-manager.nixosModules.home-manager

    # Common host configurations
    ./fish.nix
    ./locale.nix
    ./nix-ld.nix
    ./nix.nix
    ./openssh.nix
    ./upower.nix
    ./sops.nix
  ];

  home-manager = {
    # Note: Graphics-related configs (dconf, gvfs, udisks2, avahi, display-manager)
    # are now handled by modules/nixos/desktop.nix conditionally

    useGlobalPkgs = true;
    # Avoid activation failures when Home Manager starts managing a file that
    # already exists (e.g. ~/.config/mimeapps.list after enabling xdg.mimeApps).
    backupFileExtension = "hm-bak";
    extraSpecialArgs = {
      inherit inputs outputs;
    };
  };
}
