# NixOS modules index - exports all NixOS modules
# Imported via outputs.nixosModules in flake.nix
{
  # Main module that conditionally imports users, desktop, and server modules
  # This is the entry point that should be imported by hosts
  default = import ./main.nix;
  
  # Individual modules (can be imported directly if needed)
  users = import ./users.nix;
  desktop = import ./desktop.nix;
  server = import ./server.nix;
}
