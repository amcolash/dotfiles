[[ ! -f "/sys/class/dmi/id/product_name" ]] && return
[[ "$(<"/sys/class/dmi/id/product_name")" != "DS216+" ]] && return

# Kitty won't fix it, so I will
export TERM="xterm-256color"

# Fix homebrew git message
export HOMEBREW_GIT_PATH=/usr/local/bin/git

# Override DOTFILES dir
export DOTFILES="$HOME/scripts/dotfiles"

alias dl="docker compose logs -f"

# Restart a service with docker compose
docker-restart() {
  if [ $# -ne 1 ]; then
    echo "Usage: docker-restart [docker-compose.yml directory]"
    return 1 # Exit but do not kill shell
  fi

  pushd $1 >/dev/null

  docker compose down
  docker compose up -d

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

  # after upgrade, prune old stuff
  echo Pruning images
  docker image prune -f

  echo Pruning networks
  docker network prune -f

  echo Pruning build cache
  docker builder prune -f
}

# Upgrade a docker container based on directory
docker-upgrade() {
  if [ ! -f docker-compose.yml ] && [ $# -ne 1 ]; then
    echo "Usage: docker-upgrade [docker-compose.yml directory]"
    return 1 # Exit but do not kill shell
  fi

  if [ $# -ne 0 ]; then
    pushd $1 >/dev/null
  fi

  if [ -f ./upgrade.sh ]; then
    ./upgrade.sh
  elif [ -f docker-compose.yml ]; then
    if [ -d .git ] || [ -d ../.git ]; then
      git pull || {
        printf >&2 "ERROR: git pull failed, please see log."
        return 1
      }
    fi

    docker compose pull --ignore-buildable
    docker compose build --pull

    # only restart if containers are already running
    if [ $(docker compose ps -q | wc -l) != 0 ]; then
      #docker-compose down
      docker compose up -d --force-recreate
    fi
  fi

  if [ $# -ne 0 ]; then
    popd >/dev/null
  fi
}

# Archive an old docker directory
docker-archive() {
  if [ $# -ne 1 ]; then
    echo "Usage: docker-archive [docker-compose.yml directory]"
    return 1 # Exit but do not kill shell
  fi

  pushd $1 >/dev/null
  docker compose down
  popd >/dev/null
  mv $1 $HOME/docker/old
}
