if [ -d "$HOME/.bashrc.d" ]; then
  for script in "$HOME/.bashrc.d"/*; do
    if [ -f "$script" ] && [ -r "$script" ]; then
      source "$script"
    fi
  done
fi
