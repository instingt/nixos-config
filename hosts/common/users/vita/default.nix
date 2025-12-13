{ config, pkgs, ... }:
{
  users.users.vita = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    shell = pkgs.bash;
  };

  home-manager.users.vita = import ../../../../home/${config.networking.hostName}.nix;
}
