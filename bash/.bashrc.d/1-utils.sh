# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
  # alias ls="ls --color=auto"
  #alias dir="dir --color=auto"
  #alias vdir="vdir --color=auto"

  alias grep="grep --color=auto"
  alias fgrep="fgrep --color=auto"
  alias egrep="egrep --color=auto"
fi

# Custom aliases
alias reboot="sudo reboot && exit"
alias shutdown="sudo shutdown now"
alias weather="curl https://wttr.in"
alias ncu="npx npm-check-updates"

# override `ls` to use `eza` if available
if [ $(command -v eza) ]; then
  export EZA_CONFIG_DIR="$HOME/.config/eza"

  alias ls="eza --group-directories-first --color=always"
  alias ll="eza --long --group-directories-first --color=always"
  alias la="eza --all --long --group-directories-first --color=always"
  alias l="eza -CF --group-directories-first --color=always"
else
  alias ls="ls --color=auto"
  alias ll="ls -l"
  alias la="ls -la"
  alias l="ls -CF"
fi

# use neovim if available
if [ $(command -v nvim) ]; then
  alias nv="nvim"
  alias vi="nvim"
  alias vim="nvim"
fi

# meld fallback
if [ ! "$(command -v meld)" ]; then
  alias meld="diff"
fi

# better default search for rg (search hidden files, exclude git)
if [ $(command -v rg) ]; then
  alias rg="rg --hidden --glob '!.git'"
fi

# use bat instead of cat
if [ $(command -v bat) ]; then
  export BAT_THEME="ansi"
  alias cat_orig="$(command -v cat)"
  alias cat="bat"
fi

if [ $(command -v brew) ]; then
  alias brew_upgrade="brew upgrade && brew upgrade --cask"
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
