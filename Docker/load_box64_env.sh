#!/bin/bash

# Path to the configuration file
CONFIG_FILE="$s/BepInEx/addition_stuff/box64.rc"

# Check if the file exists
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "File $CONFIG_FILE not found."
    exit 1
fi

# Read and process each line
while IFS= read -r line; do
    # Skip empty lines and comments
    [[ -z "$line" || "$line" =~ ^# ]] && continue

    # If the line starts with BOX64_, export it as an environment variable
    if [[ "$line" == BOX64_* ]]; then
        export "$line"
        echo "export $line"
    fi
done < "$CONFIG_FILE"
