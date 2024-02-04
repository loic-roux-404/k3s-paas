# K3s PaaS

- [Documentation](https://loic-roux-404.github.io/k3s-paas/)
- [Original tutorial (FR)](https://github.com/esgi-lyon/paas-tutorial/blob/main/docs/index.md)

## New Nix system (beta)

### Setup (Darwin)

If you don't have these experimental features enabled, you can enable them with :

```bash
echo 'extra-experimental-features = nix-command flakes' | sudo tee /etc/nix/nix.conf

```

Boot the builder :

```bash
nix develop .#builder --command zsh
```

To uninstall the builder inside darwin env :

```bash
./result/sw/bin/darwin-uninstaller
```

### Build vm

```bash
nix build .#nixosConfigurations.default --system 'aarch64-linux' --max-jobs 8 --refresh
```

Patch result for darwin compatibility :

> Note : binaries in this script are linux builds.

```bash
sudo sed -i -E 's|/nix/store[^ ]*bin/||g; /^export PATH/d; s|bash|/usr/bin/env bash|g; s/kvm/hvf/g; s/-nographic[^ ]*-serial mon:stdio/-daemonize/g' result/bin/run-k3s-paas-vm
```

## Start Machine

```bash
QEMU_NET_OPTS="hostfwd=tcp::2222-:22," ./result/bin/run-k3s-paas-vm
```

### Terraform local setup

Switch shell to ops environment with all required tools :

```bash
nix develop .#ops
```

Bootstrap terraform :

```bash
terraform init
terraform apply -auto-approve
```
