#!/usr/bin/env bash

eval "$(jq -r '@sh "key=\(.key) args=\(.args)"')"

OUTPUT=$(ssh-to-age "${args:-}" < "$key")

jq -n --arg output "$OUTPUT" '{"key": $output}'
