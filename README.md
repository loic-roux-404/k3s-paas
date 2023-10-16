# K3s PaaS
```bash
echo 'experimental-features = nix-command flakes' | sudo tee -a /etc/nix/nix.conf

```

- [Documentation](https://loic-roux-404.github.io/k3s-paas/)
- [Original tutorial (FR)](https://github.com/esgi-lyon/paas-tutorial/blob/main/docs/index.md)


## New Nix system (beta)

Docker runtime is required, tested on :
- Rancher


Build linux image with nixos flakes

Qemu :

```bash
docker run -it -v $(pwd):/data -v $PWD/docker/nix:/etc/nix -w/data \
    --privileged nixos/nix:2.18.1 nix build .#qcow
```

Docker :

```bash
docker run -it -v $(pwd):/data -v $PWD/docker/nix:/etc/nix -w/data \
    --privileged nixos/nix:2.18.1 nix build .#docker
```

## Test nix Os vm

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
