#!/bin/bash

if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <word> [author]"
    exit 1
fi

WORD="$1"   # First argument
AUTHOR="${2:-Isael}" # Second argument, or 'username' if not provided

# List of repository directories
REPOS=(
  "./"
  # Add paths to other repositories as needed
)

# Output file
OUTPUT_FILE="/tmp/git_search_output.txt"

# Clear the output file if it exists
: > "$OUTPUT_FILE"

for REPO in "${REPOS[@]}"
do
  echo "Searching in repository: $REPO" | tee -a "$OUTPUT_FILE"
  cd "$REPO" || continue
  
  # Initialize and update submodules
  git submodule update --init --recursive
  
  # Iterate over all submodules
  git submodule foreach --recursive "
    echo 'Searching in submodule: '\$name'' | tee -a '$OUTPUT_FILE';
    git log --all -S'$WORD' --author='$AUTHOR' --oneline | tee -a '$OUTPUT_FILE';
  "
  
  # Search in the main repository
  git log --all -S"$WORD" --author="$AUTHOR" --oneline | tee -a "$OUTPUT_FILE"
done

echo "Search completed. Results saved to $OUTPUT_FILE"


