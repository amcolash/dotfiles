if [ ! -f /etc/NIXOS ]; then
  return
fi

export NIXPKGS_ALLOW_UNFREE=1

alias rebuild="sudo nixos-rebuild -I nixos-config=$DOTFILES/nixos/configuration.nix switch"
alias rebuild_bootloader="rebuild --install-bootloader"
alias update="sudo nix-channel --update"

# optionally allow passing in a filename instead of getting a vim picker
function nix() {
  if [ "$#" -ne 1 ]; then
    vim $DOTFILES/nixos/
  else
    vim $DOTFILES/nixos/$1.nix
  fi
}
