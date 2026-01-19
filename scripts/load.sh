#!/usr/bin/env bash
set -euo pipefail

# move to the script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
pushd "$SCRIPT_DIR/.." > /dev/null

# display name mappings for directories
declare -A DISPLAY_NAMES
DISPLAY_NAMES["copied"]="system settings"

# create reverse mapping for lookup
declare -A DIR_NAMES

# find all directories with load.sh scripts
OPTIONS=()
LOAD_DIRS=()
TEMP_OPTIONS=()

for dir in */ ; do
  dir_name=$(basename "$dir")
  if [ -f "$dir/load.sh" ] && [ "$dir" != "templates/" ] && [ "$dir" != "scripts/" ]; then
    # use display name if available, otherwise use directory name
    display_name="${DISPLAY_NAMES[$dir_name]:-$dir_name}"
    TEMP_OPTIONS+=("$display_name|||$dir_name")
  fi
done

# sort by display name and build final OPTIONS array
IFS=$'\n' sorted=($(sort <<<"${TEMP_OPTIONS[*]}"))
unset IFS

for item in "${sorted[@]}"; do
  display_name=$(echo "$item" | cut -d'|' -f1)
  dir_name=$(echo "$item" | cut -d'|' -f4)
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
set +e
CHOICES=$(whiptail --title "Load Settings" --checklist \
  "Select modules to load:" 20 78 15 \
  "${OPTIONS[@]}" 3>&1 1>&2 2>&3)
exitstatus=$?
set -e

[[ $exitstatus != 0 ]] && echo "[!] Loading Cancelled." && exit 0

# parse selected choices
SELECTED_ARRAY=()
for choice in $CHOICES; do
  SELECTED_ARRAY+=($(echo "$choice" | sed 's/"//g'))
done

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
