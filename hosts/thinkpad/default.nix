{
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix

    ../common/global
    ../common/users/vita

    ../common/optional/regreet.nix
    ../common/optional/quietboot.nix
    ../common/optional/pipewire.nix
  ];

  networking.hostName = "thinkpad";
  networking.networkmanager.enable = true;

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_xanmod_latest;

  system.stateVersion = "25.11";
}
