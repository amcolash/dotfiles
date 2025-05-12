#!/usr/bin/env bash

set -euo pipefail

# Local install locations
TARGET_BASE="$HOME/.local/share/cinnamon"

mkdir -p "$TARGET_BASE/applets" "$TARGET_BASE/extensions"

echo "Restoring Cinnamon spices using sparse Git checkout..."

# Function to install a spice using sparse checkout
clone_sparse_spice() {
  local uuid=$1              # e.g., cinnamon-maximus@fmete
  local spice_type=$2        # "applets" or "extensions"
  local repo="https://github.com/linuxmint/cinnamon-spices-$spice_type.git"
  local spice_repo_path="$uuid/files/$uuid"
  local local_target="$TARGET_BASE/$spice_type/$uuid"

  echo " -> Installing $spice_type: $uuid"

  # Create a temporary dir
  tmpdir=$(mktemp -d)
  pushd "$tmpdir" > /dev/null

  git init -q
  git remote add origin "$repo"
  git config core.sparseCheckout true

  echo "$spice_repo_path/" > .git/info/sparse-checkout
  git pull --depth 1 origin master > /dev/null 2>&1

  mkdir -p "$local_target"
  cp -r "$spice_repo_path/." "$local_target/"

  popd > /dev/null
  rm -rf "$tmpdir"
}

# Install from a spice list file
install_spices_from_list() {
  local list_file=$1
  local spice_type=$2

  while read -r uuid; do
    [ -z "$uuid" ] && continue
    if [ ! -d "$TARGET_BASE/$spice_type/$uuid" ]; then
      clone_sparse_spice "$uuid" "$spice_type"
    else
      echo " -> $spice_type already installed: $uuid"
    fi
  done < "$list_file"
}

# Restore from lists
install_spices_from_list "applets.txt" "applets"
install_spices_from_list "extensions.txt" "extensions"

# Restart cinnamon
pkill -HUP cinnamon

echo "✅ All Cinnamon spices restored successfully."

