# This file is sourced before any other scripts in the .bashrc.d directory.

# Load linux homebrew
if [ -d /home/linuxbrew/.linuxbrew ] && [ ! -f /etc/NIXOS ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

if [ "$(uname)" != "Darwin" ]; then
  if command -v fc-list >/dev/null 2>&1; then
    if fc-list :family | grep -qi "SauceCodePro Nerd Font Mono"; then
      HAS_NERD_FONT=1
    fi
  fi
else
  if system_profiler SPFontsDataType 2>/dev/null | grep -q "SauceCodeProNerdFontMono"; then
    HAS_NERD_FONT=1
  fi
fi
