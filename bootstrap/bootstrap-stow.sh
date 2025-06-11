#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
pushd "$SCRIPT_DIR/../" > /dev/null

# List of directories to exclude from the whiptail menu
EXCLUDE_DIRS=("nixos" "bootstrap" "dconf" "cinnamon" "flatpak" "brew" "copied" )

# Hide some dotfiles if they are not applicable (mapping of [command:directory])
declare -a COMMAND_DIR_MAP=(
  "hyprland:hypr"
  "kitty:kitty"
  "cinnamon:spices"
  "waybar:waybar"
  "alacritty:alacritty"
)

# Iterate over the defined command-to-directory mappings
for item in "${COMMAND_DIR_MAP[@]}"; do
  # Temporarily set IFS to ':' to split the string into command and directory
  IFS=':' read -r command_name dir_name <<< "$item"

  # Check if the command exists silently
  if [ ! $(command -v "$command_name") ]; then
    # If the command is not found, add its corresponding directory to EXCLUDE_DIRS
    EXCLUDE_DIRS+=("$dir_name")
  fi
done

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
set +e
CHOICES=$(whiptail --title "Stow Dotfiles" --checklist \
"Choose the dotfiles you want to stow:" 20 78 15 \
"${OPTIONS[@]}" 3>&1 1>&2 2>&3)
set -e

exitstatus=$?

if [[ -z "$CHOICES" || $exitstatus != 0 ]]; then
  echo "[!] No choices selected or stow cancelled."
else
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
