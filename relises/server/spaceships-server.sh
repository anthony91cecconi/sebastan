#!/bin/sh
printf '\033c\033]0;%s\a' spaceshipsserver
base_path="$(dirname "$(realpath "$0")")"
"$base_path/spaceships-server.x86_64" "$@"
