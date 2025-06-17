# Dotfile Update Check, from gemini
DOTFILES_REPO="$HOME/Github/dotfiles"
LAST_UPDATE_CHECK_FILE="$HOME/.dotfile_update"
CHECK_INTERVAL_SECONDS=$((60 * 60 * 24)) # 24 hours

# Function to check for updates
check_dotfiles_updates() {
  echo "󱓎 Checking for dotfile updates..."

  # Basic git check (requires being in the dotfiles repo or knowing its path)
  if [ -d "$DOTFILES_REPO" ]; then
    pushd "$DOTFILES_REPO" > /dev/null
    git remote update > /dev/null 2>&1
    LOCAL_REV=$(git rev-parse @{u})
    REMOTE_REV=$(git rev-parse HEAD)
    popd > /dev/null

    if [ "$LOCAL_REV" != "$REMOTE_REV" ]; then
      echo "󱓊 Dotfile updates available!"
    fi
  else
    return 1
  fi

  # Update the last checked timestamp
  date +%s > "$LAST_UPDATE_CHECK_FILE"
}

# Check if the last update file exists and if enough time has passed
if [ ! -f "$LAST_UPDATE_CHECK_FILE" ]; then
  check_dotfiles_updates
else
  LAST_CHECK_TIMESTAMP=$(cat "$LAST_UPDATE_CHECK_FILE")
  CURRENT_TIMESTAMP=$(date +%s)
  TIME_DIFF=$((CURRENT_TIMESTAMP - LAST_CHECK_TIMESTAMP))

  if [ "$TIME_DIFF" -ge "$CHECK_INTERVAL_SECONDS" ]; then
    check_dotfiles_updates
  fi
fi