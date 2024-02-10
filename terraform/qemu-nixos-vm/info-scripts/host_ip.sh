#!/usr/bin/env bash

set -e

IP=$(ifconfig | grep 'inet ' | grep -Fv '127.0.0.1' | awk '{print $2}' | head -n1)

jq -n --arg ip "$IP" '{"result":$ip}'
