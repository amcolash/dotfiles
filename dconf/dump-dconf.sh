#!/usr/bin/env bash
set -e

# move to the script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
pushd "$SCRIPT_DIR" > /dev/null

# List of dconf paths to export
PATHS=(
  "/org/cinnamon/"
  "/org/gnome/meld/"
)

for path in "${PATHS[@]}"; do
  # Strip leading slash and trailing slash
  clean_path="${path#/}"
  clean_path="${clean_path%/}"

  filename="${clean_path//\//.}.conf"

  echo "Exporting $path -> $filename"
  dconf dump "$path" > "$filename"
done

popd > /dev/null