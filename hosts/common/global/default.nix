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

  home-manager.useGlobalPkgs = true;
  home-manager.extraSpecialArgs = {
    inherit inputs outputs;
  };
}
