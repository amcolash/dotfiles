#!/usr/bin/env bash
set -euo pipefail

echo "[+] Saving installed Cinnamon spices..."

ls ~/.local/share/cinnamon/applets    > "applets.txt"
ls ~/.local/share/cinnamon/extensions > "extensions.txt"
