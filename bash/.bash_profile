# Source bashrc for login shells (like TTY)
if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi

# Set up rust/cargo if installed
if [ -f "$HOME/.cargo/env" ]; then
  . "$HOME/.cargo/env"
fi