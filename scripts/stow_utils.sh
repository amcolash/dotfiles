#!/bin/bash

# Path Setup
LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$LIB_DIR/.." && pwd)"
TARGET_DIR="$HOME"

get_stowable_packages() {
  local EXCLUDE_DIRS=("nixos" "bootstrap" "system" "templates" "scripts")
  local COMMAND_DIR_MAP=("hyprland:hypr" "kitty:kitty" "cinnamon:spices" "waybar:waybar" "alacritty:alacritty")

  for item in "${COMMAND_DIR_MAP[@]}"; do
    IFS=':' read -r cmd dir <<< "$item"
    if ! command -v "$cmd" >/dev/null 2>&1; then EXCLUDE_DIRS+=("$dir"); fi
  done

  for dir_path in "$DOTFILES_ROOT"/*/; do
    [ -e "$dir_path" ] || continue
    local name=$(basename "$dir_path")
    local is_excluded=false

    for ex in "${EXCLUDE_DIRS[@]}"; do
      [[ "$name" == "$ex" ]] && is_excluded=true && break
    done

    if [[ -f "${dir_path}load.sh" ]] || [[ -f "${dir_path}save.sh" ]]; then is_excluded=true; fi

    if ! $is_excluded; then echo "$name"; fi
  done
}

is_package_stowed() {
  local package="$1"
  local package_path="$DOTFILES_ROOT/$package"

  if [ ! -d "$package_path" ]; then return 0; fi

  # Use find to get every single file in the package
  while IFS= read -r file_item; do
    local rel_path="${file_item#$package_path/}"
    local home_path="$TARGET_DIR/$rel_path"

    # Now, we check the home_path AND all its parent directories
    # to see if ANY of them are a symlink pointing to our dotfiles.
    local current_check="$home_path"
    local found_link=false

    # Walk up the directory tree from the file to the home root
    while [[ "$current_check" != "$TARGET_DIR" && "$current_check" != "/" ]]; do
      if [[ -L "$current_check" ]]; then
        # Check if this link points to the corresponding path in our dotfiles
        local expected_dot_path="$package_path/${current_check#$TARGET_DIR/}"
        if [[ "$(readlink -f "$current_check")" == "$(readlink -f "$expected_dot_path")" ]]; then
          found_link=true
          break
        fi
      fi
      current_check=$(dirname "$current_check")
    done

    if [[ "$found_link" == "false" ]]; then
      [[ "${STOW_DEBUG:-}" == "true" ]] && echo >&2 "  [DEBUG] No link found in path tree for: $home_path"
      return 1
    fi
  done < <(find "$package_path" -type f)

  return 0
}
