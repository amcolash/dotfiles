#!/bin/sh

mkdir -p ~/.local/share/fonts

function install_font() {
  echo Downloading font $1

  curl -sSL -o font.zip "$1"
  unzip font.zip -d ~/.local/share/fonts
  rm -f font.zip
}

# Grab nerd fonts and install locally
install_font https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/UbuntuMono.zip
install_font https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/SourceCodePro.zip
