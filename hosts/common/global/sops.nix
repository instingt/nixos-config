{ inputs, ... }:
{
  imports = [ inputs.sops-nix.nixosModules.sops ];

  sops.defaultSopsFile = ../secrets.yaml;

  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
}
