# Exports
export DOTFILES="$HOME/Github/dotfiles"
export EDITOR="vim"
export VISUAL="vim"
export PATH="$HOME/.local/bin:$PATH"

# Tool config
export BAT_THEME="ansi"
export EZA_CONFIG_DIR="$HOME/.config/eza"

# check the window size after each command and, if necessary, update the values of LINES and COLUMNS.
shopt -s checkwinsize

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=50000
HISTFILESIZE=50000

# don't put duplicate lines or lines starting with space
HISTCONTROL=ignoreboth:erasedups

# ignore some commands from history
HISTIGNORE=”ls:ll:exit:clear:cd:top:htop*:history*:rm*”

# append to the history file, don't overwrite it
shopt -s histappend

# write a multi line command in a single line
shopt -s cmdhist

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
# shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

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

[[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]] && . "/usr/local/etc/profile.d/bash_completion.sh"