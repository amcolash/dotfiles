# Only run on non-nix linux
if [ -f /etc/NIXOS ]; then
  return
fi

update_kitty() {
  # download/update version
  curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin

  # Create symbolic links to add kitty and kitten to PATH (assuming ~/.local/bin is in your system-wide PATH)
  ln -sf ~/.local/kitty.app/bin/kitty ~/.local/kitty.app/bin/kitten ~/.local/bin/
  # Place the kitty.desktop file somewhere it can be found by the OS
  cp ~/.local/kitty.app/share/applications/kitty.desktop ~/.local/share/applications/
  # If you want to open text files and images in kitty via your file manager also add the kitty-open.desktop file
  cp ~/.local/kitty.app/share/applications/kitty-open.desktop ~/.local/share/applications/
  # Update the paths to the kitty and its icon in the kitty desktop file(s)
  sed -i "s|Icon=kitty|Icon=$(readlink -f ~)/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" ~/.local/share/applications/kitty*.desktop
  sed -i "s|Exec=kitty|Exec=$(readlink -f ~)/.local/kitty.app/bin/kitty|g" ~/.local/share/applications/kitty*.desktop
  # Make xdg-terminal-exec (and hence desktop environments that support it use kitty)
  echo 'kitty.desktop' > ~/.config/xdg-terminals.list
}

# Mostly ChatGPT for this helper function
stow_file() {
  local stow_dir="$1"
  local filename="$2"

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

  local destination_path="$DOTFILES/$stow_dir/$parent_dir_of_file/$relative_path_in_stow_dir"
  local destination_parent_dir="$(dirname "$destination_path")"

  echo "Moving '$absolute_filename' to '$destination_path'..."

  # Create the necessary directory structure in the dotfiles repo
  mkdir -p "$destination_parent_dir" || { echo "Error: Could not create directory '$destination_parent_dir'"; return 1; }

  # Move the file using sudo
  sudo mv "$absolute_filename" "$destination_path" || { echo "Error: Could not move file '$absolute_filename' to '$destination_path'"; return 1; }

  echo "Running 'stow' on '$stow_dir'..."
  sudo stow -d "$DOTFILES" -t / "$stow_dir" || { echo "Error: Stow failed for '$stow_dir'"; return 1; }

  echo "Successfully stowed '$absolute_filename' to '$DOTFILES/$stow_dir' and created symlink."
}
