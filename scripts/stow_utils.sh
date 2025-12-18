#!/bin/bash

# Get the directory where this library lives
LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXCLUDE_FILE="$LIB_DIR/stow_exclude.txt"

get_stowable_packages() {
    local dotfiles_root="$1"
    local excludes=()

    # Load exclusions
    if [[ -f "$EXCLUDE_FILE" ]]; then
        while IFS= read -r line || [[ -n "$line" ]]; do
            [[ -z "$line" || "$line" =~ ^# ]] && continue
            excludes+=("$line")
        done < "$EXCLUDE_FILE"
    fi

    # Loop through directories and filter
    for package_path in "$dotfiles_root"/*/; do
        local package=$(basename "$package_path")
        
        # Standard filters
        [[ "$package" == ".git" ]] && continue
        
        # Check against exclusion list
        local skip=0
        for ex in "${excludes[@]}"; do
            if [[ "$package" == "$ex" ]]; then
                skip=1
                break
            fi
        done

        if [[ $skip -eq 0 ]]; then
            echo "$package"
        fi
    done
}
