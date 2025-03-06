{ pkgs, ... }:
let
  storagePath = "/var/lib/nomad/storage";
in {
  systemd.tmpfiles.rules = [
    "d ${storagePath} - root root - -"
  ];

  services.nomad = {
    enable = true;
    dropPrivileges = false;

    settings = {
      server = {
        enabled = true;
        bootstrap_expect = 1;
      };

      client = {
        enabled = true;
        host_volume.default = {
          path = storagePath;
          read_only = false;
        };
        cpu_total_compute = 8000;
      };

      ui.enabled = true;
    };
  };

  services.vault = {
    enable = true;
    package = pkgs.vault-bin;

    storageBackend = "raft";
  };
}
