# Build NixOS images for local development and cloud deployment

A NixOS flake for building a [Lima](https://lima-vm.io)-compatible system image which includes HashiCorp [Nomad](https://nomadproject.io) and [Vault](https://vaultproject.io).

This is a fork of a [fork](nixos-lima/nixos-lima) (and so on) tailored to include Nomad, Vault, and other default runtime support needed for a specific set of projects.

## Usage

### Bootstrapping

First, install Nix using the [Determinate Nix Installer](https://docs.determinate.systems/getting-started/individuals/); another Nix distrubtion like [Lix](https://lix.systems/install/) could also work if Determinate fails on your machine. (Note: if you already have Nix installed you should be able to reuse it as long as it [supports Flakes](https://nixos.wiki/wiki/flakes).)

For normal development on a Mac targeting Linux images, you can use the [linux-builder](https://nixos.org/manual/nixpkgs/unstable/#sec-darwin-builder) utility from [Nix Darwin](https://github.com/LnL7/nix-darwin):

```bash
nix run nixpkgs#darwin.linux-builder
```

This will bring up a minimal NixOS VM capable of building Nix packages for Linux. This VM is functionally equivalent to the hidden VM that Docker and Podman use on macOS, and the `linux-builder` utility is explicitly _not_ designed to serve as a base VM for more general-purpose use.

You can configure this helper to run in the background persistently, as well as configure your global Nix configuration to automatically use it by adding it to your system configuration via nix-darwin:

```bash
darwin-rebuild switch --flake .#localdev
```

Once the builder is running via either method, you can build the disk image needed to run the NixOS VM under lima:

```bash
nix build .#packages.aarch64-linux.img
```

This will put a raw disk image for the guest VM in the standard Nix `result/` directory.

## Running NixOS

```bash
limactl start --name=nixos nixos.yaml
```

You should be able to access Nomad, Vault, et. al. directly from the host system, but if you need to troubleshoot or work directly inside the VM you can get a shell via `limactl`:

```
limactl shell nixos
```

## Rebuilding NixOS inside the Lima instance

```bash
# Using a VM shell, cd to this repository directory
nixos-rebuild switch --flake .#nixos --use-remote-sudo
```

## Accessing Nomad in Lima instance

The Nomad admin UI should be available [locally](http://localhost:4646), and the `nomad` CLI should work either from your Mac or the NixOS itself. There are example jobs in the [nomad](nomad/) directory you can use to test your install.

## References

* [NixOS Dev Environment on Mac](https://www.joshkasuboski.com/posts/nix-dev-environment/) January, 24 2023 by [Josh Kasuboski](https://www.joshkasuboski.com)

## Credits

* Forked from: [nixos-lima/nixos-lima](https://github.com/nixos-lima/nixos-lima)

## TODO

- [ ] (re-)separate reusable lima + image-build modules from runtime image dependencies
- [ ] standard Nomad jobs for e.g. ZeroTierOne, Grafana, and Postgres (+ backups)
- [ ] test + verify x86 support
