#!/usr/bin/env bash
# Report what in FILE.md will not read well on the reMarkable 2: the layout
# warnings md2rm prints. Prints nothing and exits 0 when the file is clean.
set -uo pipefail
[ $# -eq 1 ] || { echo "usage: check.sh FILE.md" >&2; exit 1; }

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

if ! log=$(RM_SYNC_DIR=$tmp md2rm "$1" 2>&1 >/dev/null); then
  echo "md2rm failed:"
  printf '%s\n' "$log" | tail -20
  exit 1
fi
printf '%s\n' "$log" | grep '^md2rm:' || true
