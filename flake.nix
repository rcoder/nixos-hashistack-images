{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, flake-utils, nixos-generators, ... }@attrs: 
    let
      ful = flake-utils.lib;
      pkgs-for = system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      
      devShells = ful.eachDefaultSystem (system: {
        devShells.default = with (pkgs-for system); mkShell {
          packages = [
            just
            lima
            nomad
            vault-bin
          ];
        };
      });
    in
    ful.eachSystem [ ful.system.x86_64-linux ful.system.aarch64-linux ] (system:
      {
        packages = {
          img = nixos-generators.nixosGenerate {
            pkgs = pkgs-for system;
            modules = [
              ./lima.nix
              ./modules/nomad.nix
            ];
            format = "qcow-efi";
          };
        };
      }) // { 
        nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = attrs;
          modules = [
            ./lima.nix
            ./modules/nomad.nix
          ];
        };

        nixosModules.lima = {
          imports = [ ./lima-init.nix ];
        };
      } // devShells;
}

