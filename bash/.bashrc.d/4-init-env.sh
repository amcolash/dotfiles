# Init private env var file if it doesn't exist
REPO_ENV="$DOTFILES/bash/.bashrc.d/0-env.sh"
if [ ! -f "$REPO_ENV" ]; then
  touch "$REPO_ENV"
fi
