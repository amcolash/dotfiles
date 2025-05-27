[[ ! -f "/sys/class/dmi/id/product_name" ]] && return
[[ "$(<"/sys/class/dmi/id/product_name")" != "DS216+" ]] && return

# Override DOTFILES dir
export DOTFILES="$HOME/scripts/dotfiles"

alias dot="pushd $DOTFILES"
alias bashrc="vim $DOTFILES/bash/.bashrc.d/"

# Load linux homebrew
if [ -d /home/linuxbrew/.linuxbrew ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Restart a service with docker compose
docker-restart() {
  if [ $# -ne 1 ]; then
    echo "Usage: docker-restart [docker-compose.yml directory]"
    return 1 # Exit but do not kill shell
  fi

  pushd $1

  docker-compose down
  docker-compose up -d

  popd
}

# Upgrade a docker container based on directory
docker-upgrade() {
  if [ $# -ne 1 ]; then
    echo "Usage: docker-upgrade [docker-compose.yml directory]"
    return 1 # Exit but do not kill shell
  fi

  pushd $1

  if [ -f ./upgrade.sh ]; then
    ./upgrade.sh
  else
    if [ -d .git ] || [ -d ../.git ]; then
      git pull
    fi

    docker-compose pull

    docker-compose down
    docker-compose up --build -d
  fi

  popd
}

# Archive an old docker directory
docker-archive() {
  if [ $# -ne 1 ]; then
    echo "Usage: docker-archive [docker-compose.yml directory]"
    return 1 # Exit but do not kill shell
  fi

  pushd $1
  docker-compose down
  popd
  mv $1 ~/docker/old
}