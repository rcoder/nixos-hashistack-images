stage0:
    nix run nixpkgs#darwin.linux-builder

stage1:
    nix run nix-darwin#darwin-rebuild -- switch --flake .#localdev

build:
    nix build .#packages.aarch64-linux.img

create-vm: build
    limactl create --name=nixos nixos.yaml || true

run-vm: create-vm
    limactl start nixos || true
    limactl shell nixos
