#!/usr/bin/env bash
set -euo pipefail

# check if pacman can be used
if ! command -v pacman &> /dev/null; then
  echo "[!] pacman is not installed. Skipping saving."
  exit 0
fi

echo "[+] Saving pacman (native) packages..."

# move to the script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
pushd "$SCRIPT_DIR" > /dev/null

# pactree is required for deep dependency filtering (part of pacman-contrib)
if ! command -v pactree &> /dev/null; then
  echo "[!] pacman-contrib is required for deep filtering. Please install it: sudo pacman -S pacman-contrib"
  exit 1
fi

echo "    -> Fetching real base package list from CachyOS GitHub..."
# Fetch the official CachyOS installer package list (Timeout after 10s to be safe)
CACHY_YAML=$(curl -sL --max-time 10 https://raw.githubusercontent.com/CachyOS/cachyos-calamares/master/src/modules/netinstall/netinstall.yaml || echo "")
# Parse out all the raw package names from the yaml structure
CACHY_WEB_PKGS=$(echo "$CACHY_YAML" | grep -oP '^\s+-\s+\K[a-zA-Z0-9_.-]+$' || true)

echo "    -> Discovering OS infrastructure dependencies (this may take a few seconds)..."

# 1. Groups that represent desktop environments
IGNORED_GROUPS="plasma kde-applications kde-utilities xorg gnome gnome-extra xfce4 xfce4-goodies"

# 2. Known top-level system packages (base OS, network, printing, audio)
IGNORED_ROOTS="base base-devel linux linux-cachyos systemd cups bluez networkmanager alsa-utils pulseaudio pipewire sddm ufw bash-completion bind ethtool foomatic-db foomatic-db-engine foomatic-db-gutenprint-ppds foomatic-db-nonfree foomatic-db-nonfree-ppds foomatic-db-ppds fsarchiver fwupd logrotate lsb-release man-db man-pages mkinitcpio net-tools netctl inetutils fprintd"

# Get all packages in those groups
GROUP_PKGS=$(pacman -Qqg $IGNORED_GROUPS 2>/dev/null || true)

# Dynamically find all cachyos meta/base packages they might have
CACHY_PKGS=$(pacman -Qq | grep -E "^(cachyos-)" || true)

# Combine everything into a giant list of OS roots
ALL_ROOTS=$(echo -e "$GROUP_PKGS\n$IGNORED_ROOTS\n$CACHY_PKGS\n$CACHY_WEB_PKGS" | tr ' ' '\n' | sort -u | grep -v '^$')

# 3. Find every single nested dependency for all of these OS packages
# We use parallel processing (16 jobs) to speed this up massively.
# CRITICAL OPTIMIZATION: We dropped the '-s' (sync db) flag so pactree ONLY 
# queries your local installed database. This prevents it from re-parsing 
# 50MB of remote repository metadata 400 times, dropping the time from ~20s to ~1s!
TMP_DIR=$(mktemp -d)
echo "$ALL_ROOTS" | xargs -P 16 -I {} sh -c "pactree -u '{}' > \"$TMP_DIR/{}.txt\" 2>/dev/null || true"

# Combine and deduplicate the massive dependency tree
ALL_DEPS=$(cat "$TMP_DIR"/*.txt 2>/dev/null | sort -u || true)
rm -rf "$TMP_DIR"

# 4. Regex for hardware-specific and dynamic installer choices made by Calamares Python scripts
# (Bootloaders, GPU Drivers, Filesystems, Microcodes, Fonts)
CACHY_DYNAMIC_REGEX="^(limine.*|grub|efibootmgr|systemd-boot|os-prober|.*-ucode|btrfs-progs|xfsprogs|e2fsprogs|f2fs-tools|dosfstools|exfatprogs|jfsutils|lvm2|mdadm|dmraid|mtools|xf86-video-.*|lib32-.*|vulkan-.*|mesa-.*|opencl-.*|rocm-.*|xorg-.*|xrt.*|ttf-.*|.*-fonts|usbutils|s-nail|libcurl-.*)$"

# 5. Filter the native explicitly installed packages
if [ -n "$ALL_DEPS" ]; then
  pacman -Qqen | grep -vFxf <(echo "$ALL_DEPS") | grep -vE "$CACHY_DYNAMIC_REGEX" > pacman.txt
else
  pacman -Qqen | grep -vE "$CACHY_DYNAMIC_REGEX" > pacman.txt
fi

if command -v paru &> /dev/null; then
  echo "[+] Saving paru (AUR) packages..."
  # -m: foreign (AUR packages)
  pacman -Qqem > paru.txt
else
  echo "[-] paru is not installed. Skipping AUR packages."
fi

popd > /dev/null
