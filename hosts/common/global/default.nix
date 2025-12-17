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

  home-manager.useGlobalPkgs = true;
  home-manager.extraSpecialArgs = {
    inherit inputs outputs;
  };
}
