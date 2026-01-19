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

# go to the script directory
pushd "$SCRIPT_DIR" > /dev/null

echo "[+] Installing fonts..."

mkdir -p ~/.local/share/fonts

function install_font() {
  FONT=$(basename "$1" .zip)
  FONT_DIR="$HOME/.local/share/fonts/$FONT"

  if [ -d "$FONT_DIR" ]; then
    echo "[=] Font $FONT already installed. Skipping."
    return
  fi

  echo Downloading font $FONT
  curl -sSL -o $FONT.zip "$1"

  mkdir -p $FONT_DIR
  unzip $FONT.zip -d $FONT_DIR

  rm -f $FONT.zip
}

# Grab nerd fonts and install locally
install_font https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/UbuntuMono.zip "UbuntuMono Nerd Font"
install_font https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/SourceCodePro.zip "SourceCodePro Nerd Font"

# Refresh font cache
echo "[+] Refreshing font cache..."
fc-cache -f ~/.local/share/fonts