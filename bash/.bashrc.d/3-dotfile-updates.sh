# Dotfile Update Check, from gemini
LAST_UPDATE_CHECK_FILE="$HOME/.dotfile_update"
CHECK_INTERVAL_SECONDS=$((60 * 60 * 24)) # 24 hours

# Function to check for updates
check_dotfiles_updates() {
  echo "  Checking for dotfile updates..."

  # Basic git check (requires being in the dotfiles repo or knowing its path)
  if [ -d "$DOTFILES" ]; then
    pushd "$DOTFILES" > /dev/null
    git remote update > /dev/null 2>&1
    LOCAL_REV=$(git rev-parse @{u})
    REMOTE_REV=$(git rev-parse HEAD)
    popd > /dev/null

    # Update the last checked timestamp
    date +%s > "$LAST_UPDATE_CHECK_FILE"

    # Once check complete, overwrite the previous line with the result
    if [ "$LOCAL_REV" != "$REMOTE_REV" ]; then
      echo -e "\e[1A\e[K  Dotfile updates available!  "
    else
      echo -e "\e[1A\e[K  Dotfiles are up to date."
      return 0
    fi
  else
    return 1
  fi
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