#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
pushd "$SCRIPT_DIR/../" > /dev/null

# List of directories to exclude from the whiptail menu
EXCLUDE_DIRS=("nixos" "bootstrap" "dconf" "cinnamon" )

# Hide some dotfiles if they are not applicable
if ! command -v hyprland >/dev/null; then
  EXCLUDE_DIRS+=("hypr")
fi

if ! command -v waybar >/dev/null; then
  EXCLUDE_DIRS+=("waybar")
fi

if ! command -v cinnamon >/dev/null; then
  EXCLUDE_DIRS+=("spices")
fi

# Build the whiptail menu options
OPTIONS=()

# Iterate over directories and exclude the ones in EXCLUDE_DIRS
for dir in */ ; do
  name="${dir%/}"
  EXCLUDED=false
  for exclude in "${EXCLUDE_DIRS[@]}"; do
    if [[ "$name" == "$exclude" ]]; then
      EXCLUDED=true
      break
    fi
  done

  if ! $EXCLUDED ; then
    OPTIONS+=("$name" "" "ON")
  fi
done

# Generate the whiptail menu
CHOICES=$(whiptail --title "Stow Dotfiles" --checklist \
"Choose the dotfiles you want to stow:" 20 78 15 \
"${OPTIONS[@]}" 3>&1 1>&2 2>&3)

exitstatus=$?

if [ $exitstatus = 0 ]; then
  echo "[+] Stowing selected dotfiles..."
  echo
  # Iterate over the selected choices (which are space-separated)
  for choice in $CHOICES; do
    # Remove quotes from the choice
    clean_choice=$(echo "$choice" | sed 's/"//g')

    if stow "$clean_choice"; then
      echo "  [✓] Successfully stowed $clean_choice"
    else
      echo
      echo "  [!] Failed to stow $clean_choice"
      echo
    fi
  done
fi

popd > /dev/null
