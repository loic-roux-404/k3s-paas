#!/usr/bin/env bash

nix develop .#builder --command nix build .#nixosConfigurations.default --system 'aarch64-linux' --max-jobs 8 --refresh

sudo sed -i -E 's|/nix/store[^ ]*bin/||g; /^export PATH/d;
    s|! bash|! /usr/bin/env bash|g; s/kvm/hvf/g;
    s/-serial mon:stdio//g; s/"M"/8G/;
    s/-m 1024/-m 8192/; s/^exec/nohup/g; s/"$@"$/"$@" \&/g;' "$(readlink result/bin/run-k3s-paas-vm)"
