#!/usr/bin/env bash
set -euo pipefail

echo
echo "[+] Starting dotfiles bootstrap"

if ! command -v git &> /dev/null; then
  if command -v apt &> /dev/null; then
    echo "[*] Attempting to install git using apt..."
    sudo apt update
    sudo apt install -y git
  elif command -v pacman &> /dev/null; then
    echo "[*] Attempting to install git using pacman..."
    sudo pacman -Sy --noconfirm git
  elif command -v dnf &> /dev/null; then
    echo "[*] Attempting to install git using dnf..."
    sudo dnf install -y git
  else
    echo "[!] Git is required to bootstrap system and use homebrew. Please install it with your OS package manager."
    exit 1
  fi
fi

# Try to locate brew in standard paths and set up the environment
find_and_load_brew() {
  if command -v brew &> /dev/null; then
    return 0
  fi

  local brew_paths=(
    "/opt/homebrew/bin/brew"
    "/usr/local/bin/brew"
    "/home/linuxbrew/.linuxbrew/bin/brew"
    "$HOME/.linuxbrew/bin/brew"
  )

  for path in "${brew_paths[@]}"; do
    if [[ -x "$path" ]]; then
      eval "$("$path" shellenv bash)"
      return 0
    fi
  done

  return 1
}

if find_and_load_brew; then
  echo "[✓] Homebrew is installed"
else
  read -p "[?] Homebrew appears to be missing, would you like to install it? [y/N] " install_brew < /dev/tty

  if [[ "$install_brew" =~ ^[Yy]$ ]]; then
    curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash

    if find_and_load_brew; then
      echo "[✓] Homebrew installed and activated"
    else
      echo "[!] Failed to find Homebrew after installation. You may need to add it to your PATH manually."
    fi
  fi
fi

# Check for required programs before running script
for cmd in unzip stow ssh-keygen whiptail; do
  if ! command -v "$cmd" &> /dev/null; then
    echo "[!] Missing required command: $cmd"

    # Attempt to install the missing command with Homebrew if available
    if command -v brew &> /dev/null; then
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

# Function to test SSH connection to GitHub.
# It captures output in a global variable `SSH_OUTPUT` and returns 0 on success.
test_github_ssh() {
  # We temporarily disable `exit on error` because `ssh -T` to GitHub
  # exits with 1 on a successful authentication. We want to handle this
  # specific exit code as a success case.
  set +e
  SSH_OUTPUT=$(ssh -T git@github.com -o BatchMode=yes -o ConnectTimeout=5 -o StrictHostKeyChecking=accept-new 2>&1)
  local exit_code=$?
  set -e

  # Check for the specific success case: exit code 1 and "successfully authenticated" in the output.
  if [[ $exit_code -eq 1 ]] && echo "$SSH_OUTPUT" | grep -q "successfully authenticated"; then
    return 0 # Success
  else
    return 1 # Failure
  fi
}

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
if test_github_ssh; then
  echo "[✓] SSH key is already registered with GitHub."
else
  echo
  echo "$SSH_OUTPUT"
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
  elif command -v brave-browser &> /dev/null; then
    brave-browser $GITHUB_URL &
  elif command -v google-chrome &> /dev/null; then
    google-chrome $GITHUB_URL &
  elif command -v firefox &> /dev/null; then
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
if [[ -f /sys/class/dmi/id/product_name && "$(cat /sys/class/dmi/id/product_name)" == "DS216+" ]]; then
  ROOT_DIR=~/scripts/
fi

# Create the root directory if it doesn't exist
mkdir -p "$ROOT_DIR"
cd "$ROOT_DIR"

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

# Define DOTFILES for the nixos-rebuild step below
DOTFILES="$ROOT_DIR/dotfiles"

# 4. Stow configs interactively
echo
bootstrap/bootstrap-stow.sh

# 5. Load additional settings (cinnamon, dconf, etc.)
echo
./scripts/load.sh

# 5. Prompt for nixos-rebuild
if [[ -f /etc/NIXOS ]]; then
  echo
  echo "[*] Running nixos-rebuild"
  # write device name to a file for all nix builds (to optionally configure things as necessary)
  cat /sys/class/dmi/id/product_name > "$DOTFILES/nixos/device.txt"
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
