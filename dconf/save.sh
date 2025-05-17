#!/usr/bin/env bash
set -euo pipefail

# move to the script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
pushd "$SCRIPT_DIR" > /dev/null

if [ ! $(command -v dconf) ]; then
  echo "[!] dconf is not installed. Skipping saving."
else
  echo "[+] Saving dconf settings..."

  # List of dconf paths to export
  PATHS=(
    "/org/cinnamon/"
    "/org/gnome/meld/"
    "/org/gnome/desktop/"
  )

  for path in "${PATHS[@]}"; do
    # Strip leading slash and trailing slash
    clean_path="${path#/}"
    clean_path="${clean_path%/}"

    filename="${clean_path//\//.}.conf"

    echo "[*] Exporting $path -> $filename"
    dconf dump "$path" > "$filename"
  done
fi

popd > /dev/null
