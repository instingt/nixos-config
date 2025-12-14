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
    ../common/optional/docker.nix
  ];

  networking.hostName = "thinkpad";
  networking.networkmanager.enable = true;

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_xanmod_latest;

  system.stateVersion = "25.11";

  # import ssh keys for vita@thinkpad
  sops.secrets."ssh/id_ed25519" = {
    sopsFile = ../common/secrets.yaml;
    key = "vita-id_ed25519";
    owner = "vita";
    group = "users";
    mode = "0600";
    path = "/home/vita/.ssh/id_ed25519";
  };

  sops.secrets."ssh/id_ed25519_pub" = {
    sopsFile = ../common/secrets.yaml;
    key = "vita-id_ed25519_pub";
    owner = "vita";
    group = "users";
    mode = "0644";
    path = "/home/vita/.ssh/id_ed25519.pub";
  };
}
