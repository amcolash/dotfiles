# ~/.bashrc: executed by bash(1) for non-login shellparses.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# Exit now if in scp session (None of the below is necessary)
if [ -z "$PS1" ]; then
  return
fi

# Exports
export DOTFILES="$HOME/Github/dotfiles"
export EDITOR="vim"
export VISUAL="vim"

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

# Git branch for PS1
parse_git_branch() {
  git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

[[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]] && . "/usr/local/etc/profile.d/bash_completion.sh"

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
# shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# use starship if possible, otherwise fall back to old manual PS1
if [ $(command -v starship) ]; then
  eval "$(starship init bash)"

  export STARSHIP_SESSION=$(starship session)
  export SESSION_DIR=~/.sessionStack

  # make session stack dir (to keep track of pushed dirs)
  mkdir -p $SESSION_DIR

  # remove sessions older than 7 days
  find $SESSION_DIR -atime +7 -delete

  # custom functions to set a file to indicate if the directory stack is active
  pushd() {
    builtin pushd "$@"
    dirs -v | wc -l > $SESSION_DIR/$STARSHIP_SESSION
  }

  popd() {
    builtin popd "$@"
    dirs -v | wc -l > $SESSION_DIR/$STARSHIP_SESSION
  }
else
  # set a fancy prompt (non-color, unless we know we "want" color)
  case "$TERM" in
  xterm-color|*-256color|xterm-kitty) color_prompt=yes ;;
  esac

  if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\] \[\033[01;34m\]\w `parse_git_branch`$\[\033[00m\] '
  else
    PS1='\u@\h \w \$ '
  fi
  unset color_prompt

  # If this is an xterm set the title to user@host:dir
  case "$TERM" in
  xterm* | rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
  *) ;;
  esac
fi

# use ble.sh for better line completion + auto complete
# (nixos)
if [ $(command -v blesh-share) ]; then
  source "$(blesh-share)"/ble.sh --attach=none
  [[ ! ${BLE_VERSION-} ]] || ble-attach
fi

# ble.sh (non-nix)
if [ -f ~/.local/share/blesh/ble.sh ]; then
  source ~/.local/share/blesh/ble.sh
fi

# standard bash history settings when not using ble.sh
if [ ! $(command -v ble) ]; then
  # don't put duplicate lines or lines starting with space in the history.
  # See bash(1) for more options
  HISTCONTROL=ignoreboth

  # append to the history file, don't overwrite it
  shopt -s histappend

  # for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
  HISTSIZE=10000
  HISTFILESIZE=20000
fi

# use atuin for better history
if [ $(command -v atuin) ]; then
  eval "$(atuin init bash)"
fi

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
  alias ls='ls --color=auto'
  #alias dir='dir --color=auto'
  #alias vdir='vdir --color=auto'

  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
  . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
  . /etc/bash_completion
fi
