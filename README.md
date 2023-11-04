# K3s PaaS

- [Documentation](https://loic-roux-404.github.io/k3s-paas/)
- [Original tutorial (FR)](https://github.com/esgi-lyon/paas-tutorial/blob/main/docs/index.md)

## New Nix system (beta)

### Setup (Darwin)

Boot the builder :

```bash
nix build .#darwinConfigurations.builder.system && \
result/sw/bin/darwin-rebuild switch --flake .#builder

```

You will probably need : 

```bash
sudo chown $USER:staff /etc/nix/builder_ed25519`

```

### Build vm

```bash
nix build .#nixosConfigurations.default --system 'aarch64-linux' --max-jobs 8 --refresh
```

## Test nix Os vm

## Qemu

> Need to adjust binaries by removing /nix/store prefix because commands of this script are linux builds.

```bash
QEMU_NET_OPTS="hostfwd=tcp::2222-:22," PATH="$PATH:$(dirname $(which readlink))" ./result/bin/run-k3s-paas-vm
```

In fish : 

``fish
set QEMU_NET_OPTS "hostfwd=tcp::2222-:22,"
./result/bin/run-k3s-paas-vm
```

### Docker

- TODO

### Libvirt (no network)

1. In a first shell start libvirt with :

```bash
libvirtd -d
```

Network (optional) : `virsh -c qemu:///session net-start default`

1. Then

```bash
terraform init
terraform apply -auto-approve
```
