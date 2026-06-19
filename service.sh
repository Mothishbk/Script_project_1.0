#!/bin/bash
set -x
# debugging enabled

source file_folder.sh
# Directory creation
mkdir -p "$backup_file_dir"

services=($(cat $service_source_file))

# received services in array
for serv in "${services[@]}"; do
    if systemctl is-active --quiet "$serv"; then
        echo "The given $serv is running" >> "$backup_file_name"
    else
        echo "$serv will be restarting soon............."
        sudo systemctl restart "$serv"
        echo "SERVICE: $serv is restarted now safely" >> "$backup_file_name"
    fi
done
