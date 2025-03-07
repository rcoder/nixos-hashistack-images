{ pkgs, ... }:
{
  nix = {
    settings = {
      trusted-users = [ "root" "@admin" ];
      experimental-features = [ "nix-command" "flakes" ];
      builders-use-substitutes = true;
      substituters = [
         "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };

    linux-builder = {
      enable = true;
      maxJobs = 4;
      ephemeral = true;

      config = {
        zramSwap.enable = true;
        nix.settings.experimental-features = [ "nix-command" "flakes" ];

        virtualisation = {
          darwin-builder = {
            diskSize = 50*1024;
            memorySize = 8*1024;
          };
          cores = 6;
        };

        nixpkgs.config.allowUnfree = true;
      };
    };
  };


  system.stateVersion = 6;
}
