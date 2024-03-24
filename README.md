# K3s PaaS

- [Documentation](https://loic-roux-404.github.io/k3s-paas/)
- [Original tutorial (FR)](https://github.com/esgi-lyon/paas-tutorial/blob/main/docs/index.md)

## New Nix system (beta)

### Setup (Darwin)

Start builder environment setting up nix.conf, darwin services, packages and linux builder vm :

```bash
nix --extra-experimental-features 'nix-command flakes' develop .#builder

```

One liner to set up darwin and build the system :

```bash
cd terraform
nix develop .#builder --command nix build .#nixosConfigurations.default --system 'aarch64-linux' --max-jobs 8 --refresh
```

This starts dnsmasq in background, you might need to force a refresh of the dns cache :

```bash
sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder
```

To uninstall the builder inside darwin env :

```bash
./result/sw/bin/darwin-uninstaller
```

### Terraform local setupc

```bash
cd terraform
```

Bootrap local vm :

```bash
terraform -chdir=libvirt init
terraform -chdir=libvirt apply -auto-approve
```

Setup k8s modules :

```bash
terraform init
terraform apply -auto-approve
```


## Cheat Sheet

### Libvirt

Undefine pool :

```bash
virsh -c qemu:///system pool-undefine libvirt-pool-k3s-paas
```

Undefine vm to avoid conflicts :

```bash
virsh -c qemu:///system undefine --nvram vm1
```

Open console :

```bash
virsh -c qemu:///system console vm1
```

Exit with `Ctrl + +` or `Ctrl + ]` on linux.

> See [this SO thread](https://superuser.com/questions/637669/how-to-exit-a-virsh-console-connection#:~:text=ctrl%20%2B%20alt%20%2B%206%20(Mac)) if you keep struggling.


### Openssl

Generate a sha512crypt password :

```bash
openssl passwd -salt zizou -6 zizou420!
```
