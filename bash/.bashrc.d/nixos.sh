if [ ! -f /etc/NIXOS ]; then
  return
fi

alias rebuild="cat /sys/class/dmi/id/product_name > $DOTFILES/nixos/device.txt && sudo nixos-rebuild -I nixos-config=$DOTFILES/nixos/configuration.nix switch"
alias update="sudo nix-channel --update"

# optionally allow passing in a filename instead of getting a vim picker
function nix() {
  if [ "$#" -ne 1 ]; then
    vim $DOTFILES/nixos/
  else
    vim $DOTFILES/nixos/$1.nix
  fi
}

# enable ble.sh
source "$(blesh-share)"/ble.sh --attach=none
[[ ! ${BLE_VERSION-} ]] || ble-attach

# atuin
eval "$(atuin init bash)"
