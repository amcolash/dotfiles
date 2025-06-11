#!/usr/bin/env bash
set -euo pipefail

# move to the script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
pushd "$SCRIPT_DIR" > /dev/null

echo "[+] Saving settings..."
echo

for dir in */ ; do
  if [ -f "$dir/save.sh" ]; then
    pushd "$dir" > /dev/null
    ./save.sh
    popd > /dev/null
  fi
done

echo
echo "[✓] Saving complete."