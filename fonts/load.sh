#!/usr/bin/env bash
set -euo pipefail

# get the script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DIRNAME=$(basename "$SCRIPT_DIR")

# only install fonts for linux
if [ "$(uname)" == "Darwin" ]; then
  echo "[-] MacOS detected. Skipping font install."
  exit 0
fi

# check if user wants to load brew
read -p "Would you like to load $DIRNAME? [y/N] " do_load < /dev/tty
if [[ ! "$do_load" =~ ^[Yy]$ ]]; then
  echo "[-] Skipping $DIRNAME."
  exit 0
fi

# go to the script directory
pushd "$SCRIPT_DIR" > /dev/null

echo "[+] Installing fonts..."

mkdir -p ~/.local/share/fonts

function install_font() {
  FONT=$(basename "$1" .zip)
  echo Downloading font $FONT
  curl -sSL -o $FONT.zip "$1"

  mkdir -p ~/.local/share/fonts/$FONT
  unzip $FONT.zip -d ~/.local/share/fonts/$FONT

  rm -f $FONT.zip
}

# Grab nerd fonts and install locally
install_font https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/UbuntuMono.zip
install_font https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/SourceCodePro.zip

# Refresh font cache
fc-cache -fv ~/.local/share/fonts