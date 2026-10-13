# This file is sourced before any other scripts in the .bashrc.d directory.

# Detect Operating System and Environment
case "$(uname)" in
  Darwin)
    export IS_MACOS=1
    ;;
  Linux)
    export IS_LINUX=1
    if [ -f "/etc/NIXOS" ]; then
      export IS_NIXOS=1
    fi
    if [ -f "/sys/class/dmi/id/product_name" ] && [ "$(cat /sys/class/dmi/id/product_name 2>/dev/null)" = "DS216+" ]; then
      export IS_NAS=1
    fi
    ;;
esac

# Load linux homebrew
if [ -d /home/linuxbrew/.linuxbrew ] && [ -z "$IS_NIXOS" ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Attempt to check if NerdFont is installed
if [ -z "$IS_MACOS" ]; then
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

# If we have nerdfont AND using supported terminal, use enhanced starship config
# Additionally, if in an SSH session, we likely are using a terminal with nerdfonts set up
if [ $HAS_NERD_FONT ] && [ "$TERM" != "linux" ] || [ -n "$SSH_TTY" ]; then
  export BASIC_STARSHIP=0
else
  export BASIC_STARSHIP=1
fi
