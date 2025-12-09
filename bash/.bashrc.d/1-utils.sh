# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
  # alias ls='ls --color=auto'
  #alias dir='dir --color=auto'
  #alias vdir='vdir --color=auto'

  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

# Custom aliases
alias reboot="sudo reboot && exit"
alias shutdown="sudo shutdown now"
alias weather="curl https://wttr.in"
alias ncu="npx npm-check-updates"

# override `ls` to use `eza` if available
if [ $(command -v eza) ]; then
  alias ls='eza --group-directories-first --color=always'
  alias ll='eza --long --group-directories-first --color=always'
  alias la='eza --all --long --group-directories-first --color=always'
  alias l='eza -CF --group-directories-first --color=always'
else
  alias ls='ls --color=auto'
  alias ll='ls -l'
  alias la='ls -A'
  alias l='ls -CF'
fi

# use neovim if available
if [ $(command -v nvim) ]; then
  alias vi='nvim'
  alias vim='nvim'
fi

# helpful apt commands
if [ $(command -v apt) ]; then
  alias upgrade="sudo apt update && sudo apt upgrade"
  alias updateInstall="sudo apt update && sudo apt install"
fi

# Dotfile helper functions
dot() {
  pushd $DOTFILES > /dev/null
}

dotpull() {
  pushd $DOTFILES > /dev/null
  git pull
  popd > /dev/null
}

bashrc() {
  vim $DOTFILES/bash/.bashrc.d/
}
