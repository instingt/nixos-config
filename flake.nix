{
  description = "Vita NixOS on ThinkPad";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    systems.url = "github:nix-systems/default-linux";

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Third party programs, packaged with nix
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
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
      treefmt-nix,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      lib = nixpkgs.lib // home-manager.lib;
      supportedSystems = import systems;
      overlays = import ./overlays;

      mkPkgs =
        system:
        import nixpkgs {
          inherit system;
          overlays = builtins.attrValues overlays;
          config.allowUnfree = true;
        };

      pkgsFor = lib.genAttrs supportedSystems mkPkgs;
      forEachSystem = f: lib.genAttrs supportedSystems (system: f pkgsFor.${system});

      treefmtEval = lib.genAttrs supportedSystems (
        system: treefmt-nix.lib.evalModule pkgsFor.${system} ./treefmt.nix
      );

    in
    {
      inherit lib;

      homeManagerModules = import ./modules/home-manager;
      nixosModules = import ./modules/nixos;
      packages = forEachSystem (pkgs: import ./pkgs { inherit pkgs; });
      inherit overlays;
      devShells = forEachSystem (pkgs: import ./devShells.nix { inherit pkgs; });
      formatter = lib.mapAttrs (_: v: v.config.build.wrapper) treefmtEval;
      checks = lib.genAttrs supportedSystems (system: {
        treefmt = treefmtEval.${system}.config.build.check self;
      });

      nixosConfigurations = {
        thinkpad = lib.nixosSystem {
          system = "x86_64-linux";
          pkgs = pkgsFor.x86_64-linux;
          modules = [ ./hosts/thinkpad ];
          specialArgs = {
            inherit inputs outputs;
          };
        };
      };
    };
}
