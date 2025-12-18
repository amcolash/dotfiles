#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")/../scripts" && pwd)"
source "$SCRIPT_DIR/stow_utils.sh"

cd "$DOTFILES_ROOT"

OPTIONS=()
STOWED_BEFORE=()
packages=$(get_stowable_packages)

for pkg in $packages; do
  if is_package_stowed "$pkg"; then
    OPTIONS+=("$pkg" "" "ON")
    STOWED_BEFORE+=("$pkg")
  else
    OPTIONS+=("$pkg" "" "OFF")
  fi
done

set +e
CHOICES=$(whiptail --title "Stow Dotfiles" --checklist \
  "Select packages to sync. Unchecking will UNSTOW." 20 78 15 \
  "${OPTIONS[@]}" 3>&1 1>&2 2>&3)
exitstatus=$?
set -e

[[ $exitstatus != 0 ]] && echo "[!] Cancelled." && exit 0

SELECTED_ARRAY=()
for choice in $CHOICES; do SELECTED_ARRAY+=($(echo "$choice" | sed 's/"//g')); done

echo "[+] Syncing dotfiles..."
for pkg in $packages; do
  IS_SELECTED=false
  for s in "${SELECTED_ARRAY[@]}"; do [[ "$s" == "$pkg" ]] && IS_SELECTED=true && break; done

  WAS_STOWED=false
  for s in "${STOWED_BEFORE[@]}"; do [[ "$s" == "$pkg" ]] && WAS_STOWED=true && break; done

  if $IS_SELECTED; then
    stow -R -d "$DOTFILES_ROOT" -t "$TARGET_DIR" "$pkg"
    echo "  [✓] Stowed $pkg"
  elif $WAS_STOWED; then
    stow -D -d "$DOTFILES_ROOT" -t "$TARGET_DIR" "$pkg"
    echo "  [X] Unstowed $pkg"
  fi
done
