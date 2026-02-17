[[ ! -f "/sys/class/dmi/id/product_name" ]] && return
[[ "$(<"/sys/class/dmi/id/product_name")" != "DS216+" ]] && return

# Kitty won't fix it, so I will
export TERM="xterm-256color"

# Fix homebrew git message
export HOMEBREW_GIT_PATH=/usr/local/bin/git

# Override DOTFILES dir
export DOTFILES="$HOME/scripts/dotfiles"

# Restart a service with docker compose
docker-restart() {
  if [ $# -ne 1 ]; then
    echo "Usage: docker-restart [docker-compose.yml directory]"
    return 1 # Exit but do not kill shell
  fi

  pushd $1 >/dev/null

  docker-compose down
  docker-compose up -d

  popd >/dev/null
}

# Upgrade all docker containers
docker-upgrade-all() {
  for dir in $HOME/docker/*; do
    if [ -d "$dir" ]; then
      if [ -f "$dir/docker-compose.yml" ] || [ -f "$dir/upgrade.sh" ]; then
        echo "Upgrading $dir"
        docker-upgrade "$dir"
      fi
    fi
  done
}

# Upgrade a docker container based on directory
docker-upgrade() {
  if [ $# -ne 1 ]; then
    echo "Usage: docker-upgrade [docker-compose.yml directory]"
    return 1 # Exit but do not kill shell
  fi

  pushd $1 >/dev/null

  if [ -f ./upgrade.sh ]; then
    ./upgrade.sh
  else
    if [ -d .git ] || [ -d ../.git ]; then
      git pull || {
        printf >&2 "ERROR: git pull failed, please see log."
        return 1
      }
    fi

    docker-compose pull
    docker-compose build

    # only restart if containers are already running
    if [ $(docker-compose ps -q | wc -l) != 0 ]; then
      docker-compose down
      docker-compose up -d
    fi
  fi

  popd >/dev/null
}

# Archive an old docker directory
docker-archive() {
  if [ $# -ne 1 ]; then
    echo "Usage: docker-archive [docker-compose.yml directory]"
    return 1 # Exit but do not kill shell
  fi

  pushd $1 >/dev/null
  docker-compose down
  popd >/dev/null
  mv $1 $HOME/docker/old
}
