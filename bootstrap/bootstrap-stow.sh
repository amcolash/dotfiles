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

[[ $exitstatus != 0 ]] && echo "[!] Stow Cancelled." && exit 0

SELECTED_ARRAY=()
for choice in $CHOICES; do SELECTED_ARRAY+=($(echo "$choice" | sed 's/"//g')); done

echo "[+] Syncing dotfiles..."
for pkg in $packages; do
  IS_SELECTED=false
  for s in "${SELECTED_ARRAY[@]}"; do [[ "$s" == "$pkg" ]] && IS_SELECTED=true && break; done

  WAS_STOWED=false
  for s in "${STOWED_BEFORE[@]}"; do [[ "$s" == "$pkg" ]] && WAS_STOWED=true && break; done

  if $IS_SELECTED; then
    # Check for conflicts first with dry-run
    if stow -n -R -d "$DOTFILES_ROOT" -t "$TARGET_DIR" "$pkg" 2>/dev/null; then
      # No conflicts, proceed normally
      stow -R -d "$DOTFILES_ROOT" -t "$TARGET_DIR" "$pkg"
      echo "  [✓] Stowed $pkg"
    else
      # Conflicts detected, use --adopt and handle interactively
      echo "  [!] Conflicts detected for $pkg, adopting existing files..."
      stow --adopt -R -d "$DOTFILES_ROOT" -t "$TARGET_DIR" "$pkg"

      # Check what files were adopted (modified in git)
      if ! git diff --quiet --exit-code "$pkg/"; then
        echo "  [?] Files were adopted, reviewing changes..."

        # Get list of modified files in this package
        modified_files=$(git diff --name-only "$pkg/" 2>/dev/null || true)

        for file in $modified_files; do
          echo ""
          echo "File: $file"
          echo "Diff (- is your dotfile, + is adopted system file):"

          # Show diff without head to avoid SIGPIPE issues
          set +e
          git diff --color=always "$file"
          set -e

          # Pause so user can read the diff
          echo ""
          read -p "Press Enter to continue..." -r

          if whiptail --defaultno --yesno "Keep adopted version of $file?\n\nYes = Keep system file\nNo = Restore your dotfile (default)" 15 70; then
            # Keep adopted file - add it to git
            git add "$file"
            echo "  [+] Kept adopted: $file"
          else
            # Restore dotfile version
            git checkout -- "$file"
            echo "  [↺] Restored dotfile: $file"
          fi
        done

        # If any files were kept (staged), commit them
        if ! git diff --cached --quiet --exit-code "$pkg/" 2>/dev/null; then
          git commit -m "Adopted system files for $pkg"
          echo "  [✓] Committed adopted files for $pkg"
        fi
      fi
      echo "  [✓] Stowed $pkg (with conflicts resolved)"
    fi
  elif $WAS_STOWED; then
    stow -D -d "$DOTFILES_ROOT" -t "$TARGET_DIR" "$pkg"
    echo "  [X] Unstowed $pkg"
  fi
done
