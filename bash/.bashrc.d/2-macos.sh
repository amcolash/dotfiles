if [ "$(uname)" != "Darwin" ]; then
  return
fi

# Hide zsh warning
export BASH_SILENCE_DEPRECATION_WARNING=1

# Homebrew
export PATH=/opt/homebrew/bin:$PATH

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH=$BUN_INSTALL/bin:$PATH

# mise
#if [ -f "$HOME/.local/bin/mise" ]; then
#  eval "$(~/.local/bin/mise activate bash)"
#fi

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

# Increase vitest debugging output
export DEBUG_PRINT_LIMIT=500000

# pre-commit skip
export SKIP=trufflehog

# Turn on "fast-mode" for building with csr app
export FAST_MODE=enabled

# set empty variable to get yarn happy enough to run
export CODEARTIFACT_AUTH_TOKEN=""

# Aliases
alias build_backend="pushd $GROW_HOME && dotenv && DOCKER_BUILDKIT=1 docker compose build backend --build-arg FONTAWESOME_NPM_AUTH_TOKEN_ARG=${FONTAWESOME_NPM_AUTH_TOKEN} && popd"
alias server="pushd $GROW_HOME && grow-login && dotenv && make down && build_backend && docker-compose up db redis backend celery -d && popd"
alias server-restart="pushd $GROW_HOME && dotenv && docker-compose down backend && build_backend && docker-compose up -d backend && popd"
alias db="pushd $GROW_HOME && make reset_docker_db && make seed_payors_in_db BACKEND_CONTAINER_ID=grow-dashboard-backend-1 && popd"
alias payors="pushd $GROW_HOME && pipenv install --dev && pipenv shell \"python -m scripts.add_payors --execute --debug; exit\" && popd"
alias clients="cd $GROW_HOME/grow-therapy-frontend && grow-login && dotenv && (docker stop grow-dashboard-ssr-1 || true) && bun codegen && yarn install --frozen-lockfile && waitForServer && NEXT_PUBLIC_PROJECT=SSR_APP npx nx run-many --target=serve --all --parallel"
alias startFast="fastCodegen && yarn run segment-dev && yarn nx serve csr-app"
alias client="cd $GROW_HOME/grow-therapy-frontend && grow-login && dotenv && yarn install --frozen-lockfile && waitForServer && startFast"
alias storybook="cd $GROW_HOME/grow-therapy-frontend && dotenv && bun run storybook"
#alias grow="cd $GROW_HOME && pipenv shell"
alias nuke="cd $GROW_HOME && docker-compose down && docker system prune --all --force && docker volume prune --all --force"
alias rebuild="cd $GROW_HOME && git checkout main && git pull && server && client"
alias owners="codeowners \$(git diff --name-only main) | grep -v \"provider-coordination\|unowned\""
alias viz="pushd $GROW_HOME/grow-therapy-frontend/apps/csr-app && npx vite-bundle-visualizer && popd"
alias grow-login='echo yes | grow login > /dev/null && eval "$(grow shellenv)"'
alias sc="server && client"
alias start_fresh="nuke && server && waitForServer && db"
alias logs="pushd $GROW_HOME && docker-compose logs -f"
alias codegen="pushd $GROW_HOME/grow-therapy-frontend && waitForServer && yarn codegen && popd"
alias gd="git diff main"
alias sprout_local="useLocal $GROW_HOME/../sprout-ui @growtherapy/sprout-ui"

exp() {
  rg -l "export .* $1"
}

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

# checkout main version of file
cm() {
  if [ ! "$1" ]; then
    echo Checkout main version of a file from $GROW_HOME
    echo Usage: cm [filename]
    return 1
  fi

  pushd $GROW_HOME > /dev/null
  git checkout main -- $1
  popd > /dev/null
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

# use a local version of a module via npm-pack-here
useLocal() {
  if [ "$#" -ne 2 ]; then
    echo "Usage: useLocal [module path] [module name]"
    exit 1
  fi

  echo "Setting up local version of $1"

  cd $GROW_HOME/grow-therapy-frontend

  npm-pack-here -t "$1"
  yarn add "$2@file:local_modules/$2"
  yarn install

  npm-pack-here watch -t "$1"
}

fastCodegen() {
  echo "Checking for codegen updates..."

  SCHEMA=$(curl -s 'http://provider.growtherapylocal.com:5000/graphql?' \
  -H 'content-type: application/json' \
  --data-raw '{"query":"\nquery IntrospectionQuery {\n  __schema {\n\nqueryType { name }\nmutationType { name }\nsubscriptionType { name }\ntypes {\n  ...FullType\n}\ndirectives {\n  name\n  description\n  \n  locations\n  args {\n...InputValue\n  }\n}\n  }\n}\n\nfragment FullType on __Type {\n  kind\n  name\n  description\n  \n  fields(includeDeprecated: true) {\nname\ndescription\nargs {\n  ...InputValue\n}\ntype {\n  ...TypeRef\n}\nisDeprecated\ndeprecationReason\n  }\n  inputFields {\n...InputValue\n  }\n  interfaces {\n...TypeRef\n  }\n  enumValues(includeDeprecated: true) {\nname\ndescription\nisDeprecated\ndeprecationReason\n  }\n  possibleTypes {\n...TypeRef\n  }\n}\n\nfragment InputValue on __InputValue {\n  name\n  description\n  type { ...TypeRef }\n  defaultValue\n  \n  \n}\n\nfragment TypeRef on __Type {\n  kind\n  name\n  ofType {\nkind\nname\nofType {\n  kind\n  name\n  ofType {\nkind\nname\nofType {\n  kind\n  name\n  ofType {\nkind\nname\nofType {\n  kind\n  name\n  ofType {\nkind\nname\n  }\n}\n  }\n}\n  }\n}\n  }\n}\n  ","operationName":"IntrospectionQuery"}')

  MD5=$(echo "$SCHEMA" | md5sum)
  OLD_MD5=""

  if [ "$1" == "-f" ]; then
    echo "Force regenerating codegen files..."
    rm -f "$HOME/.grow/schema.md5"
  fi

  if [ -f "$HOME/.grow/schema.md5" ]; then
    OLD_MD5=$(cat "$HOME/.grow/schema.md5")
  fi

  if [ "$MD5" != "$OLD_MD5" ]; then
    echo "Generating new codegen files..."
    rm -f "$HOME/.grow/schema.md5"
    npx nx codegen csr-app && npx nx codegen data-access && echo "$MD5" > "$HOME/.grow/schema.md5"
  else
    echo "Codegen files are up to date. Force rebuild with 'yarn codegen -f'"
  fi

  echo
}

# Aggressive errors on yarn install failures
yarn() {
  if [[ "$1" == "install" ]]; then
    # Use 'command' to find the original yarn binary, bypassing our function
    command yarn install "${@:2}"
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
      echo -e "\n\033[1;31m❌ YARN INSTALL FAILED ❌\033[0m\n"
      return $exit_code
    fi
  else
    # For all other 'yarn' commands, just run the original
    command yarn "$@"
  fi
}
