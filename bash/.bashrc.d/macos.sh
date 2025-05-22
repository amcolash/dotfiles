if [ "$(uname)" != "Darwin" ]; then
  return
fi

# Hide zsh warning
export BASH_SILENCE_DEPRECATION_WARNING=1
export CODEARTIFACT_AUTH_TOKEN=""

# Homebrew
export PATH=/opt/homebrew/bin:$PATH

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH=$BUN_INSTALL/bin:$PATH

# mise
eval "$(~/.local/bin/mise activate bash)"

# override pushd/popd from mise to include dir stack
if [ $(command -v starship) ]; then
  pushd() {
    __zsh_like_cd pushd "$@"
    dirs -v | wc -l > $SESSION_DIR/$STARSHIP_SESSION
  }

  popd() {
    __zsh_like_cd popd "$@"
    dirs -v | wc -l > $SESSION_DIR/$STARSHIP_SESSION
  }
fi

# Increase max node memory (14gb, pretty insane)
export NODE_OPTIONS="--max-old-space-size=14336"

# Turn on "fast-mode" for building with csr app
export FAST_MODE=enabled

# Aliases
alias build_backend="pushd $GROW_HOME && dotenv && DOCKER_BUILDKIT=1 docker compose build backend --build-arg FONTAWESOME_NPM_AUTH_TOKEN_ARG=${FONTAWESOME_NPM_AUTH_TOKEN} && popd"
alias server="pushd $GROW_HOME && grow-login && dotenv && make down && build_backend && docker-compose up db redis backend celery -d && popd"
alias server-restart="pushd $GROW_HOME && dotenv && docker-compose down backend && build_backend && docker-compose up -d backend && popd"
alias db="pushd $GROW_HOME && make reset_docker_db && make seed_payors_in_db BACKEND_CONTAINER_ID=grow-dashboard-backend-1 && popd"
alias payors="pushd $GROW_HOME && pipenv install --dev && pipenv shell \"python -m scripts.add_payors --execute --debug; exit\" && popd"
alias clients="cd $GROW_HOME/grow-therapy-frontend && grow-login && dotenv && (docker stop grow-dashboard-ssr-1 || true) && bun codegen && yarn install --frozen-lockfile && waitForServer && NEXT_PUBLIC_PROJECT=SSR_APP npx nx run-many --target=serve --all --parallel"
alias client="cd $GROW_HOME/grow-therapy-frontend && grow-login && dotenv && yarn install --frozen-lockfile && waitForServer && bun start csr-app"
alias storybook="cd $GROW_HOME/grow-therapy-frontend && dotenv && bun run storybook"
#alias grow="cd $GROW_HOME && pipenv shell"
alias nuke="cd $GROW_HOME && docker-compose down && docker system prune --all --force && docker volume prune --all --force"
alias rebuild="cd $GROW_HOME && git checkout main && git pull && server && client"
alias owners="codeowners \$(git diff --name-only main) | grep -v \"provider-coordination\|unowned\""
alias viz="pushd $GROW_HOME/grow-therapy-frontend/apps/csr-app && npx vite-bundle-visualizer && popd"
alias grow-login='echo yes | grow login && eval "$(grow shellenv)"'
alias sc="server && client"
alias start_fresh="nuke && server && waitForServer && db"

codeartifact() {
  pushd $GROW_HOME &>/dev/null

  aws sts get-caller-identity &>/dev/null
  if [ $? != 0 ]; then
    grow login
    # aws sso login
  fi

  eval $(grow shellenv)

  #  sed -i '' "s/^CODEARTIFACT_AUTH_TOKEN=.*/CODEARTIFACT_AUTH_TOKEN=$(aws codeartifact get-authorization-token --domain grow --domain-owner 905418000668 --query authorizationToken --output text)/" .env

  popd &>/dev/null
}

dotenv() {
  if [ "$1" ]; then
    pushd $1
  fi

  if [ -f .env ]; then
    set -a
    source .env
    set +a
  fi

  if [ "$1" ]; then
    popd
  fi
}

waitForServer() {
  echo
  echo Waiting for the server to start...

  if curl -sf --retry 8 --retry-all-errors http://provider.growtherapylocal.com:5000/health-status > /dev/null; then
    echo
  else
    echo "Could not reach server, check that it is running."
  fi
}

