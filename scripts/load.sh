#!/usr/bin/env bash
set -euo pipefail

# move to the script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
pushd "$SCRIPT_DIR/.." > /dev/null

# display name mappings for directories
declare -A DISPLAY_NAMES
DISPLAY_NAMES["copied"]="system settings (copied)"

# create reverse mapping for lookup
declare -A DIR_NAMES

# find all directories with load.sh scripts
OPTIONS=()
LOAD_DIRS=()
TEMP_OPTIONS=()

for dir in */ ; do
  dir_name="${dir%/}"
  if [[ -f "$dir/load.sh" && "$dir" != "templates/" && "$dir" != "scripts/" ]]; then
    # use display name if available, otherwise use directory name
    display_name="${DISPLAY_NAMES[$dir_name]:-$dir_name}"
    TEMP_OPTIONS+=("$display_name|||$dir_name")
  fi
done

# sort by display name and build final OPTIONS array
mapfile -t sorted < <(printf '%s\n' "${TEMP_OPTIONS[@]}" | sort)

for item in "${sorted[@]}"; do
  display_name="${item%%|||*}"
  dir_name="${item##*|||}"
  OPTIONS+=("$display_name" "" "OFF")
  LOAD_DIRS+=("$display_name")
  # store reverse mapping
  DIR_NAMES["$display_name"]="$dir_name"
done

# if no loadable modules found, exit
if [ ${#LOAD_DIRS[@]} -eq 0 ]; then
  echo "[-] No loadable modules found."
  exit 0
fi

# show whiptail checklist
if ! CHOICES=$(whiptail --title "Load Settings" --checklist \
  "Select modules to load:" 20 78 15 \
  "${OPTIONS[@]}" 3>&1 1>&2 2>&3); then
  echo "[!] Loading Cancelled."
  exit 0
fi

# parse selected choices
SELECTED_ARRAY=()
if [[ -n "$CHOICES" ]]; then
  eval "SELECTED_ARRAY=($CHOICES)"
fi

# load selected modules
echo "[+] Loading saved settings..."
for selected in "${SELECTED_ARRAY[@]}"; do
  # get actual directory name from display name
  actual_dir="${DIR_NAMES[$selected]}"
  echo "[+] Loading $selected..."
  pushd "$actual_dir" > /dev/null
  ./load.sh
  popd > /dev/null
done

echo "[✓] Loading complete."
