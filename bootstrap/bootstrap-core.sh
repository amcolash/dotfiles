#!/usr/bin/env bash
set -euo pipefail

echo
echo "[+] Starting dotfiles bootstrap"

# Check for required programs before running script
for cmd in git stow ssh-keygen firefox; do
  if ! command -v "$cmd" >/dev/null; then
    echo "[!] Missing required command: $cmd"
    exit 1
  fi
done

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
  firefox --new-window https://github.com/settings/ssh/new &
  read -p "Press enter after adding your SSH key..." < /dev/tty
fi

# 3. Clone dotfiles
echo

mkdir -p ~/Github
cd ~/Github

if [[ ! -d dotfiles ]]; then
  echo "[+] Cloning dotfiles repo..."
  git clone git@github.com:amcolash/dotfiles.git
else
  echo "[=] dotfiles repo already exists"
fi

# 4. Stow configs, skipping nixos/ and bootstrap/
echo
echo "[+] Stowing dotfiles"
cd dotfiles
for dir in */ ; do
  name="${dir%/}"
  case "$name" in
    # skip these directories from using stow on them
    nixos|bootstrap|dconf)
      ;;
    *)
      echo "[*] Stowing $name"
      stow "$name"
      ;;
  esac
done

# 5. Prompt for loading d-conf (cinnamon)
echo
read -p "Would you like to load Cinnamon settings? [y/N] " do_dconf < /dev/tty
if [[ "$do_dconf" =~ ^[Yy]$ ]]; then
  echo "[*] Loading Cinnamon settings"
  dconf/load-dconf.sh
else
  echo "[=] Skipping Cinnamon load"
fi

# 5. Prompt for nixos-rebuild
if [[ -f /etc/NIXOS ]]; then
  echo
  echo "[*] Running nixos-rebuild"
  sudo nixos-rebuild -I nixos-config=nixos/configuration.nix boot
fi

echo
echo "[✓] Bootstrap complete!"
read -p "Would you like to reboot now? [y/N] " do_reboot < /dev/tty

if [[ "$do_reboot" =~ ^[Yy]$ ]]; then
  sudo reboot now
fi

