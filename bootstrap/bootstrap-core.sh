#!/usr/bin/env bash
set -euo pipefail

echo
echo "[+] Starting dotfiles bootstrap"

# Check for required programs before running script
for cmd in unzip git stow ssh-keygen whiptail; do
  if ! command -v "$cmd" >/dev/null; then
    echo "[!] Missing required command: $cmd"

    if [[ "$OSTYPE" == "darwin"* ]]; then
      echo "  [*] Attempting to install $cmd using Homebrew..."

      if $cmd == "whiptail"; then
        cmd="newt"
      fi

      brew install "$cmd"
    else
      exit 1
    fi
  fi
done

# only check for firefox for non-macOS systems
if [[ "$OSTYPE" != "darwin"* ]]; then
  if ! command -v firefox >/dev/null; then
    echo "[!] Missing required command: firefox"
    exit 1
  fi
fi

# 1. SSH key generation
echo
if [[ ! -f ~/.ssh/id_ed25519 ]]; then
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
echo "$ssh_output"

if [[ "$ssh_exit_code" -eq 1 ]] && echo "$ssh_output" | grep -q "successfully authenticated"; then
  echo "[✓] SSH key is already registered with GitHub."
else
  echo "[!] SSH key not recognized. You may need to add it to GitHub."
  echo
  echo "[*] Your SSH public key:"
  cat ~/.ssh/id_ed25519.pub
  echo
  echo "[*] Opening GitHub SSH key add page..."

  # open github ssh page - normally on mac, otherwise use firefox
  if [[ "$OSTYPE" == "darwin"* ]]; then
    open https://github.com/settings/ssh/new
  else
    firefox --new-window https://github.com/settings/ssh/new &
  fi

  read -p "Press enter after adding your SSH key..." < /dev/tty
fi

# 3. Clone dotfiles repo
echo

mkdir -p ~/Github
cd ~/Github

if [[ ! -d dotfiles ]]; then
  echo "[+] Cloning dotfiles repo..."
  git clone git@github.com:amcolash/dotfiles.git
  git submodule init
  git submodule update
else
  echo "[=] Dotfiles repo already exists"
  echo "[*] Pulling latest changes"
  git pull
  git submodule update
fi

# 4. Stow configs interactively
cd dotfiles
echo

bootstrap/bootstrap-stow.sh

# 5. Load additional settings (cinnamon, dconf, etc.)
echo
echo "[+] Loading additional settings"
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

read -p "Would you like to reboot now? [y/N] " do_reboot < /dev/tty
if [[ "$do_reboot" =~ ^[Yy]$ ]]; then
  sudo reboot now
fi
