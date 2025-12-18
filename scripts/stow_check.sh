#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/stow_utils.sh"

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo "Checking Stow status..."
echo "-----------------------"

for pkg in $(get_stowable_packages); do
  if is_package_stowed "$pkg"; then
    echo -e "${GREEN}[STOWED]${NC}   $pkg"
  else
    echo -e "${RED}[MISSING]${NC} $pkg"
  fi
done
