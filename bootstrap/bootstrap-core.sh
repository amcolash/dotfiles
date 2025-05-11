#!/usr/bin/env bash
set -euo pipefail

echo "[+] Starting dotfiles bootstrap"

# 1. SSH key generation
if [[ ! -f ~/.ssh/id_ed25519 ]]; then
  echo "[+] Generating new SSH key..."
  ssh-keygen -t ed25519 -C "$(whoami)@$(hostname)" -f ~/.ssh/id_ed25519 -N ""
else
  echo "[=] SSH key already exists"
fi

# 2. GitHub SSH setup
echo
echo "[*] Your SSH public key:"
cat ~/.ssh/id_ed25519.pub
echo
echo "[*] Opening GitHub SSH key add page..."
firefox --new-window https://github.com/settings/ssh/new &
read -p "Press enter after adding your SSH key..."

# 3. Clone dotfiles
mkdir -p ~/Github
cd ~/Github

if [[ ! -d dotfiles ]]; then
  echo "[+] Cloning dotfiles repo..."
  git clone git@github.com:<your-username>/dotfiles.git
else
  echo "[=] dotfiles repo already exists"
fi

# 4. Stow configs, skipping nixos/ and bootstrap/
cd dotfiles
for dir in */ ; do
  name="${dir%/}"
  case "$name" in
    nixos|bootstrap|dconf)
      echo "[=] Skipping $name"
      ;;
    *)
      echo "[*] Stowing $name"
      stow "$name"
      ;;
  esac
done

# 5. Prompt for loading d-conf (cinnamon)
echo
read -p "Would you like to load Cinnamon settings? [y/N] " do_dconf
if [[ "$do_dconf" =~ ^[Yy]$ ]]; then
  echo "[*] Loading Cinnamon settings"
  ../dconf/load-dconf.sh
else
  echo "[=] Skipping Cinnamon load"
fi

# 5. Prompt for nixos-rebuild
echo
read -p "Would you like to rebuild NixOS now? [y/N] " do_rebuild
if [[ "$do_rebuild" =~ ^[Yy]$ ]]; then
  echo "[*] Running nixos-rebuild switch"
  # sudo nixos-rebuild switch
  sudo nixos-rebuild -I nixos-config=nixos/configuration.nix switch
else
  echo "[=] Skipping rebuild"
fi
