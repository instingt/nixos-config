{ config, pkgs, ... }:
{
  users.users.vita = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "docker"
    ];
    shell = pkgs.fish;
    hashedPasswordFile = config.sops.secrets.vita-password.path;
  };

  sops.secrets.vita-password = {
    sopsFile = ../../secrets.yaml;
    neededForUsers = true;
  };
  home-manager.users.vita = import ../../../../home/${config.networking.hostName}.nix;
}
