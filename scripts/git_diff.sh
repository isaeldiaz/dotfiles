#!/bin/bash

# Ensure the script is receiving exactly 7 arguments from Git.
if [ $# -ne 7 ]; then
    echo "Expected 7 arguments, got $#: $*" >&2
    exit 1
fi

# Extract the file paths (arguments 1 and 2)
OLD_FILE="$1"
NEW_FILE="$2"

# If either file path is /dev/null, it indicates a file creation or deletion.
# In that case, use the existing file only.
if [ "$OLD_FILE" = "/dev/null" ]; then
    nvim "$NEW_FILE"
elif [ "$NEW_FILE" = "/dev/null" ]; then
    nvim "$OLD_FILE"
else
    nvim -d "$OLD_FILE" "$NEW_FILE"
fi

