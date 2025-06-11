# Only run on non-nix linux
if [ -f /etc/NIXOS ]; then
  return
fi

# Mostly ChatGPT for this helper function
_stow_file_internal() {
  local stow_dir="$1"
  local filename="$2"
  local dotfiles_repo="$HOME/Github/dotfiles"

  if [ -z "$stow_dir" ] || [ -z "$filename" ]; then
    echo "Usage: stow_file <stow_dir> <filename>"
    echo "  <stow_dir>: The directory inside your dotfiles repo where the file will be stowed (e.g., 'etc', 'home')."
    echo "  <filename>: The absolute or relative path to the file you want to stow."
    return 1
  fi

  local absolute_filename
  if [[ "$filename" == /* ]]; then
    absolute_filename="$filename"
  else
    absolute_filename="$(realpath "$filename")"
  fi

  if [ ! -f "$absolute_filename" ]; then
    echo "Error: File not found: $absolute_filename"
    return 1
  fi

  local relative_path_in_stow_dir
  local parent_dir_of_file="$(dirname "$absolute_filename")"

  # Determine the relative path of the file within its original parent directory
  if [[ "$parent_dir_of_file" == "/" ]]; then
    relative_path_in_stow_dir="$(basename "$absolute_filename")"
  else
    relative_path_in_stow_dir="$(realpath --relative-to="$parent_dir_of_file" "$absolute_filename")"
  fi

  local destination_path="$dotfiles_repo/$stow_dir/$parent_dir_of_file/$relative_path_in_stow_dir"
  local destination_parent_dir="$(dirname "$destination_path")"

  echo "Moving '$absolute_filename' to '$destination_path'..."

  # Create the necessary directory structure in the dotfiles repo
  mkdir -p "$destination_parent_dir" || { echo "Error: Could not create directory '$destination_parent_dir'"; return 1; }

  mv "$absolute_filename" "$destination_path" || { echo "Error: Could not move file '$absolute_filename' to '$destination_path'"; return 1; }

  echo "Running 'stow' on '$stow_dir'..."
  stow -d "$dotfiles_repo" -t / "$stow_dir" || { echo "Error: Stow failed for '$stow_dir'"; return 1; }

  echo "Successfully stowed '$absolute_filename' to '$dotfiles_repo/$stow_dir' and created symlink."
}

# This passes the entire function definition and then its call to a new bash instance run by sudo.
stow_file() {
  sudo -E bash -c "$(declare -f _stow_file_internal); _stow_file_internal \"$@\"" _ "$@"
}