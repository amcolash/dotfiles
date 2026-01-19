#!/usr/bin/env bash
set -euo pipefail

# move to the script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
pushd "$SCRIPT_DIR" > /dev/null

if [ ! $(command -v dconf) ]; then
  echo "[!] dconf is not installed. Skipping saving."
  exit 0
fi

echo "[+] Saving dconf settings..."

# List of dconf paths to export
PATHS=(
  "/com/linuxmint/updates/"
  "/org/cinnamon/"
  "/org/gnome/calculator/"
  "/org/gnome/desktop/"
  "/org/gnome/gedit/"
  "/org/gnome/meld/"
  "/org/gnome/terminal/"
)

for path in "${PATHS[@]}"; do
  # Strip leading slash and trailing slash
  clean_path="${path#/}"
  clean_path="${clean_path%/}"

  filename="${clean_path//\//.}.conf"

  echo "[*] Exporting $path -> $filename"
  dconf dump "$path" > "$filename"
done

popd > /dev/null
