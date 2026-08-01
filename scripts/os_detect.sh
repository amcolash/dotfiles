#!/usr/bin/env bash

# This script detects the base operating system and exports OS_PROFILE.
# It should be sourced, not executed directly.

if grep -qiE "arch|cachyos" /etc/os-release 2>/dev/null; then
  export OS_PROFILE="arch"
elif grep -qiE "debian|ubuntu|mint" /etc/os-release 2>/dev/null; then
  export OS_PROFILE="debian"
else
  export OS_PROFILE="unknown"
fi
