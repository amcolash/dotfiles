export DOTFILES=/home/amcolash/Github/dotfiles

alias rebuild="sudo nixos-rebuild -I nixos-config=$DOTFILES/nixos/configuration.nix switch"
alias nix="vim $DOTFILES/nixos/configuration.nix"
