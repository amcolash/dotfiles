#!/usr/bin/env bash
set -euo pipefail

echo
echo "[+] Starting dotfiles bootstrap"

# Check for required programs before running script
for cmd in unzip git stow ssh-keygen whiptail; do
  if [ ! $(command -v "$cmd") ]; then
    echo "[!] Missing required command: $cmd"

    # Attempt to install the missing command with Homebrew if available
    if [ $(command -v brew) ]; then
      echo "  [*] Attempting to install $cmd using Homebrew..."

      if [[ $cmd == "whiptail" ]]; then
        cmd="newt"
      fi

      brew install "$cmd"
    else
      exit 1
    fi
  fi
done

# 1. SSH key generation (if a key does not already exist)
echo
if [[ ! -f ~/.ssh/id_ed25519 && ! -f ~/.ssh/id_rsa ]]; then
  echo "[+] Generating new SSH key..."
  ssh-keygen -t ed25519 -C "$(whoami)@$(hostname)" -f ~/.ssh/id_ed25519 -N ""
else
  echo "[=] SSH key already exists"
fi

# 2. Check if SSH key is recognized by GitHub
echo
echo "[*] Testing SSH connection to GitHub..."
ssh_output="$(
  set +e
  ssh -T git@github.com -o BatchMode=yes -o ConnectTimeout=5 -o StrictHostKeyChecking=accept-new 2>&1
  echo $? > /tmp/ssh_exit_code
)"

ssh_exit_code=$(< /tmp/ssh_exit_code)

if [[ "$ssh_exit_code" -eq 1 ]] && echo "$ssh_output" | grep -q "successfully authenticated"; then
  echo "[✓] SSH key is already registered with GitHub."
else
  echo
  echo "$ssh_output"
  echo

  echo "[!] SSH key not recognized. You may need to add it to GitHub."
  echo

  echo "[*] Your SSH public key:"
  cat ~/.ssh/id_ed25519.pub
  echo
  echo "[*] Opening GitHub SSH key add page..."

  # open github ssh page - normally on mac, otherwise use firefox
  GITHUB_URL="https://github.com/settings/ssh/new"
  if [[ "$OSTYPE" == "darwin"* ]]; then
    open $GITHUB_URL
  elif [ $(command -v "google-chrome") ]; then
    google-chrome $GITHUB_URL &
  elif [ $(command -v "firefox") ]; then
    firefox --new-window $GITHUB_URL &
  else
    echo "[*] Please add your SSH key manually to GitHub at $GITHUB_URL"
  fi

  read -p "Press [enter] after adding your SSH key..." < /dev/tty
fi

# 3. Clone dotfiles repo
echo

# Set the root directory for dotfiles
ROOT_DIR=~/Github

  # If running on a Synology NAS, use a different directory
if [[ -f /sys/class/dmi/id/product_name &&  "$(cat /sys/class/dmi/id/product_name == "DS216+")" ]]; then
  ROOT_DIR=~/data/scripts/
fi

# Create the root directory if it doesn't exist
mkdir -p $ROOT_DIR
cd $ROOT_DIR

# Clone the repo, or update it if it already exists
if [[ ! -d dotfiles ]]; then
  echo "[+] Cloning dotfiles repo..."
  git clone git@github.com:amcolash/dotfiles.git
  cd dotfiles
  git submodule init
  git submodule update
else
  echo "[=] Dotfiles repo already exists"
  echo "[*] Pulling latest changes"
  cd dotfiles
  git pull
  git submodule update
fi

# 4. Stow configs interactively
echo
bootstrap/bootstrap-stow.sh

# 5. Load additional settings (cinnamon, dconf, etc.)
echo
./load.sh

# 5. Prompt for nixos-rebuild
if [[ -f /etc/NIXOS ]]; then
  echo
  echo "[*] Running nixos-rebuild"
  # write device name to a file for all nix builds (to optionally configure things as necessary)
  cat /sys/class/dmi/id/product_name > $DOTFILES/nixos/device.txt
  sudo nixos-rebuild -I nixos-config=nixos/configuration.nix boot
fi

echo
echo "[✓] Bootstrap complete!"

# Only prompt for reboot on NixOS
if [[ -f /etc/NIXOS ]]; then
  read -p "Would you like to reboot now? [y/N] " do_reboot < /dev/tty
  if [[ "$do_reboot" =~ ^[Yy]$ ]]; then
    sudo reboot now
  fi
fi
