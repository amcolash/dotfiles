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

# detect OS
source ../scripts/os_detect.sh

# List of dconf paths to export that are shared across all OSes
SHARED_PATHS=(
  "/org/gnome/calculator/"
  "/org/gnome/desktop/"
  "/org/gnome/gedit/"
  "/org/gnome/meld/"
  "/org/gnome/terminal/"
)

# OS-specific dconf paths
ARCH_PATHS=(
)

DEBIAN_PATHS=(
  "/com/linuxmint/updates/"
  "/org/cinnamon/"
)

mkdir -p "shared"
for path in "${SHARED_PATHS[@]}"; do
  clean_path="${path#/}"
  clean_path="${clean_path%/}"
  filename="shared/${clean_path//\//.}.conf"
  
  dump_output=$(dconf dump "$path")
  if [ -n "$dump_output" ]; then
    echo "[*] Exporting shared path $path -> $filename"
    echo "$dump_output" > "$filename"
  else
    echo "[-] Skipping $path (empty or not installed on this OS)"
  fi
done

# Select OS specific paths
OS_PATHS=()
if [ "$OS_PROFILE" = "arch" ]; then
  OS_PATHS=("${ARCH_PATHS[@]}")
elif [ "$OS_PROFILE" = "debian" ]; then
  OS_PATHS=("${DEBIAN_PATHS[@]}")
fi

if [ ${#OS_PATHS[@]} -gt 0 ]; then
  mkdir -p "$OS_PROFILE"
  for path in "${OS_PATHS[@]}"; do
    clean_path="${path#/}"
    clean_path="${clean_path%/}"
    filename="${OS_PROFILE}/${clean_path//\//.}.conf"
    
    dump_output=$(dconf dump "$path")
    if [ -n "$dump_output" ]; then
      echo "[*] Exporting ${OS_PROFILE} path $path -> $filename"
      echo "$dump_output" > "$filename"
    else
      echo "[-] Skipping $path (empty or not installed on this OS)"
    fi
  done
fi

popd > /dev/null
