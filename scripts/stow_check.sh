#!/bin/bash

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)/../"
TARGET_DIR="$HOME"

# Source the shared library
source "$DOTFILES_DIR/scripts/stow_utils.sh"

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo "Checking Stow status..."
echo "-----------------------"

# Use the function to get only the valid packages
packages=$(get_stowable_packages "$DOTFILES_DIR")

for package in $packages; do
    package_path="$DOTFILES_DIR/$package"
    all_items_stowed=true
    
    # Check top-level items (folding-aware)
    while IFS= read -r item; do
        rel_path="${item#$package_path/}"
        home_path="$TARGET_DIR/$rel_path"

        if [[ -L "$home_path" ]]; then
            # Branch is folded or file is linked correctly
            target=$(readlink -f "$home_path")
            if [[ "$target" != "$item" ]]; then
                all_items_stowed=false
            fi
        elif [[ -d "$item" && -d "$home_path" ]]; then
            # Unfolded directory: Check if children inside are linked
            while IFS= read -r sub_item; do
                sub_rel="${sub_item#$package_path/}"
                sub_home="$TARGET_DIR/$sub_rel"
                if [[ ! -L "$sub_home" ]]; then
                    all_items_stowed=false
                    break
                fi
            done < <(find "$item" -type f)
        else
            # Not a link and not a shared directory
            all_items_stowed=false
        fi
        
        [[ "$all_items_stowed" == false ]] && break
    done < <(find "$package_path" -maxdepth 1 -not -path "$package_path")

    if [ "$all_items_stowed" = true ]; then
        echo -e "${GREEN}[STOWED]${NC}   $package"
    else
        echo -e "${RED}[MISSING]${NC} $package"
    fi
done
