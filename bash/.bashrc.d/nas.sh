if [[ -f /sys/class/dmi/id/product_name && "$(cat /sys/class/dmi/id/product_name)" != "DS216+" ]]; then
  return
fi

export DOTFILES="$HOME/data/scripts/dotfiles"