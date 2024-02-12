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
nix develop .#builder
```

This starts dnsmasq in background, you might need to force a refresh of dns cache :

```bash
sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder
```

To uninstall the builder inside darwin env :

```bash
./result/sw/bin/darwin-uninstaller
```

### Build vm

```bash
./scripts/build-vm.sh
```

### Terraform local setup

```bash
cd terraform
```

Bootrap local vm :

```bash
terraform -chdir=local init
terraform -chdir=local apply -auto-approve
```

Setup k8s modules :

```bash
terraform init
terraform apply -auto-approve
```
