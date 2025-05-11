#!/usr/bin/env bash
set -e

# move to the script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
pushd "$SCRIPT_DIR" > /dev/null

for file in *.conf; do
  base=$(basename "$file" .conf)

  # Convert filename back to dconf path and add trailing slash
  dconf_path="/${base//./\/}/"

  echo "Loading $file into $dconf_path"
  dconf load "$dconf_path" < "$file"
done

popd > /dev/null