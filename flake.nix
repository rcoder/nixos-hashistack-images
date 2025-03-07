{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, flake-utils, nixos-generators, nix-darwin, ... }@attrs: 
    let
      ful = flake-utils.lib;
      devShells = ful.eachDefaultSystem (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        in {
          devShells.default = with pkgs; mkShell {
            packages = [
              cacert
              curl
              git
              just
              lima
              nomad
              vault-bin
              direnv
              qemu-utils
            ];

            shellHook = ''
              exec ${pkgs.zsh}/bin/zsh -c "just -l; zsh -i"
            '';
          };

        });
      eachLinuxSystem = cb: ful.eachSystem [ ful.system.x86_64-linux ful.system.aarch64-linux ] cb;
    in eachLinuxSystem (system:
      {
        packages = {
          img = nixos-generators.nixosGenerate {
            inherit system;

            modules = [
              { nixpkgs.config.allowUnfree = true; }
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

        darwinConfigurations.localdev = nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          modules = [ ./modules/darwin.nix ];
        };

        nixosModules.lima = {
          imports = [ ./lima-init.nix ];
        };
      } // devShells;
}

