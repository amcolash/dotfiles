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

  # Quick check: if the package directory itself is stowed
  if [[ -L "$TARGET_DIR/$package" ]]; then
    local link_target="$(readlink "$TARGET_DIR/$package")"
    if [[ "$link_target" == "$package_path" ]] || [[ "$(readlink -f "$TARGET_DIR/$package")" == "$package_path" ]]; then
      return 0
    fi
  fi

  # Check only a few files for performance, and check directories first
  local files_checked=0
  local max_files=10

  # First, check if any top-level directories are stowed
  for dir in "$package_path"/*/; do
    [ -d "$dir" ] || continue
    local dir_name=$(basename "$dir")
    local target_dir="$TARGET_DIR/$dir_name"

    if [[ -L "$target_dir" ]]; then
      local link_target="$(readlink "$target_dir")"
      if [[ "$link_target" == "$dir" ]] || [[ "$(readlink -f "$target_dir")" == "$dir" ]]; then
        return 0  # Found at least one stowed directory
      fi
    fi
  done

  # Use find to get files, but limit how many we check
  while IFS= read -r file_item && [ $files_checked -lt $max_files ]; do
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
        # Try fast readlink first, fallback to -f if needed
        local link_target="$(readlink "$current_check")"
        if [[ "$link_target" == "$expected_dot_path" ]] || [[ "$(readlink -f "$current_check")" == "$(readlink -f "$expected_dot_path")" ]]; then
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

    ((files_checked++))
  done < <(find "$package_path" -type f)

  return 0
}
