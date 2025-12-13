{
  description = "Vita NixOS on ThinkPad";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    systems.url = "github:nix-systems/default-linux";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lazyvim-config.url = "github:instingt/lazyvim-config";
    lazyvim-config.flake = false;
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      systems,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      lib = nixpkgs.lib // home-manager.lib;
      forEachSystem = f: lib.genAttrs (import systems) (system: f pkgsFor.${system});
      pkgsFor = lib.genAttrs (import systems) (
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        }
      );

    in
    {
      inherit lib;

      homeManagerModules = import ./modules/home-manager;
      packages = forEachSystem (pkgs: import ./pkgs { inherit pkgs; });
      overlays = import ./overlays { inherit inputs outputs; };

      nixosConfigurations = {
        thinkpad = lib.nixosSystem {
          modules = [ ./hosts/thinkpad ];
          specialArgs = {
            inherit inputs outputs;
          };
        };
      };
    };
}
