#!/usr/bin/env bash

ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i $ssh_connection_private_key \
    -p 2222 $ssh_connection_user@localhost \
    'ip route get 1 | awk "{print $7}" > /tmp/ip-k3s-paas.txt'
