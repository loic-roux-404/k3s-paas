#!/usr/bin/env bash

nix develop .#builder --command nix build .#nixosConfigurations.default --system 'aarch64-linux' --max-jobs 8 --refresh

sudo sed -i -E 's|/nix/store[^ ]*bin/||g; /^export PATH/d;
    s|!\sbash|! /usr/bin/env bash|g; s/kvm/hvf/g;
    s/-nographic/-daemonize/g; s/-serial mon:stdio//g' result/bin/run-k3s-paas-vm
