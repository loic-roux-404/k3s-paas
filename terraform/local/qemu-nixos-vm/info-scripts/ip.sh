#!/usr/bin/env bash

eval "$(jq -r '@sh "ssh_connection_user=\(.ssh_connection_user) ssh_connection_private_key=\(.ssh_connection_private_key)"')"

IP=$(ssh -t -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i $ssh_connection_private_key \
    -p 2222 $ssh_connection_user@localhost "ip route | grep default | grep eth0 | awk '{print \$9}' | tr -d '\n'")

jq -n --arg ip "$IP" '{"result":$ip}'
