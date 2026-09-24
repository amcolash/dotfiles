# Set up rust and cargo if installed
if [ -f "$HOME/.cargo/env" ]; then
  . "$HOME/.cargo/env"
fi

if [ $(command -v mise) ]; then
  eval "$(mise activate bash)"
fi

# use starship if possible, otherwise fall back to old manual PS1
if [ $(command -v starship) ] && [ ! -v DISABLE_STARSHIP ]; then
  # Use basic config without nerdfonts if BASIC_STARSHIP is set
  if [ ! -v BASIC_STARSHIP ] || [ "$BASIC_STARSHIP" -eq 1 ]; then
    export STARSHIP_CONFIG=~/.config/starship-basic.toml
  fi

  eval "$(starship init bash)"

  # Dynamically categorize background jobs for starship prompt
  _starship_update_jobs() {
    local vim_count=0
    local agy_count=0
    local other_count=0
    local line

    # Clear completed jobs first
    builtin jobs &>/dev/null

    while IFS= read -r line; do
      [[ -z "$line" ]] && continue
      local pid="" cmd=""
      if [[ "$line" =~ ^\[[0-9]+\][+-]?[[:space:]]+([0-9]+)[[:space:]]+[A-Za-z0-9_\ \(\)-]+[[:space:]]{2,}(.*)$ ]]; then
        pid="${BASH_REMATCH[1]}"
        cmd="${BASH_REMATCH[2]}"
      elif [[ "$line" =~ ^\[[0-9]+\][+-]?[[:space:]]+[A-Za-z0-9_\ \(\)-]+[[:space:]]{2,}(.*)$ ]]; then
        cmd="${BASH_REMATCH[1]}"
      fi

      local proc_name=""
      if [[ -n "$pid" ]]; then
        if [[ -r "/proc/$pid/comm" ]]; then
          proc_name=$(<"/proc/$pid/comm")
        elif command -v ps >/dev/null 2>&1; then
          proc_name=$(ps -p "$pid" -o comm= 2>/dev/null)
          proc_name="${proc_name##*/}"
        fi
      fi

      if [[ "$proc_name" =~ ^(vim|nvim|vi|gvim|view)$ ]] || [[ "$cmd" =~ (^|[/\ ])(vim|nvim|vi|gvim|view)($|[[:space:]]) ]]; then
        ((vim_count++))
      elif [[ "$proc_name" =~ ^(agy|antigravity)$ ]] || [[ "$cmd" =~ (^|[/\ ])(agy|antigravity)($|[[:space:]]) ]]; then
        ((agy_count++))
      else
        ((other_count++))
      fi
    done < <(builtin jobs -l 2>/dev/null)

    local out=""
    if ((vim_count > 0)); then
      if ((vim_count == 1)); then
        out+=" "
      else
        out+=" $vim_count  "
      fi
    fi
    if ((agy_count > 0)); then
      if ((agy_count == 1)); then
        out+=" "
      else
        out+=" $agy_count  "
      fi
    fi
    if ((other_count > 0)); then
      if ((other_count == 1)); then
        out+=" "
      else
        out+=" $other_count  "
      fi
    fi

    export STARSHIP_JOBS_OUTPUT="${out%  }"
  }

  starship_precmd_user_func="_starship_update_jobs"

  # Restore window title to process name when foregrounding
  fg() {
    local job_spec="${1:-%+}"
    local job_line
    job_line=$(builtin jobs "$job_spec" 2>/dev/null)
    if [[ -n "$job_line" ]]; then
      local cmd=""
      if [[ "$job_line" =~ ^\[[0-9]+\][+-]?[[:space:]]+[A-Za-z0-9_\ \(\)-]+[[:space:]]{2,}(.*)$ ]]; then
        cmd="${BASH_REMATCH[1]}"
      fi
      local first_word="${cmd%% *}"
      local proc_name="${first_word##*/}"
      if [[ -n "$proc_name" ]]; then
        printf "\033]0;%s\007" "$proc_name"
      fi
    fi
    builtin fg "$@"
  }

  export STARSHIP_SESSION=$(starship session)
  export SESSION_DIR=~/.sessionStack

  # make session stack dir (to keep track of pushed dirs)
  mkdir -p $SESSION_DIR

  # remove sessions older than 7 days
  find $SESSION_DIR -type f -atime +7 -delete

  # custom functions to set a file to indicate if the directory stack is active
  if [ $(command -v mise) ]; then
    # override pushd/popd from mise to include dir stack
    pushd() {
      __zsh_like_cd pushd "$@"
      dirs -v | wc -l >$SESSION_DIR/$STARSHIP_SESSION
    }

    popd() {
      __zsh_like_cd popd "$@"
      dirs -v | wc -l >$SESSION_DIR/$STARSHIP_SESSION
    }
  else
    pushd() {
      builtin pushd "$@"
      dirs -v | wc -l >$SESSION_DIR/$STARSHIP_SESSION
    }

    popd() {
      builtin popd "$@"
      dirs -v | wc -l >$SESSION_DIR/$STARSHIP_SESSION
    }
  fi
else
  # set a fancy prompt (non-color, unless we know we "want" color)
  case "$TERM" in
  xterm-color | *-256color | xterm-kitty) color_prompt=yes ;;
  esac

  if [ "$color_prompt" = yes ]; then
    # Git branch for PS1
    parse_git_branch() {
      git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
    }

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

# load fzf for bash history (via ctrl-r/up arrow). for now, fd is also required
if [ $(command -v fzf) ] && [ $(command -v fd) ]; then
  if [ ! "$(command -v bat)" ]; then
    echo WARNING: bat is not installed. fzf might not work
  fi

  # Use fd and set up exclusions
  FD_EXCLUDES="--hidden --exclude .git --exclude node_modules --exclude target --exclude .gemini"

  export FZF_DEFAULT_COMMAND="fd --type f $FD_EXCLUDES"
  export FZF_CTRL_T_COMMAND="fd $FD_EXCLUDES"
  export FZF_ALT_C_COMMAND="fd --type d $FD_EXCLUDES"

  #export FZF_THEME="--color=fg:#a7adba,fg+:#d0d0d0,bg:-1,bg+:#262626
  #--color=hl:#6699cc,hl+:#5fd7ff,info:#fac863,marker:#5fb3b3
  #--color=prompt:#fac863,spinner:#5fb3b3,pointer:#5fb3b3,header:#6699cc
  #--color=border:#262626,label:#aeaeae,query:#d9d9d9"
  #

  export FZF_THEME="--ansi --color=16 --color=pointer:green"
  export FZF_DEFAULT_OPTS="--height 75% --bind 'tab:accept' --extended --tiebreak=begin,length,index $FZF_THEME"

  if [ $(command -v eza) ]; then
    export FZF_CTRL_T_OPTS=" \
    --preview 'if [ -d {} ]; then \
       tree -C {}; \
     else \
       eza -l --icons --git --color=always {}; \
       if file -b --mime-type {} | grep -q \"^text/\"; then \
         bat -n --color=always {}; \
       fi \
     fi' \
    --bind 'ctrl-/:change-preview-window(down|hidden|)'"
  else
    export FZF_CTRL_T_OPTS=" \
    --preview 'bat -n --color=always {}' \
    --bind 'ctrl-/:change-preview-window(down|hidden|)'"
  fi

  export FZF_CTRL_R_OPTS=" \
  --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort' \
  --color header:italic \
  --header 'Press CTRL-Y to copy command into clipboard'"

  export FZF_ALT_C_OPTS="--preview 'tree -C {}'"

  # use fzf for history (when pressing arrow up)
  bind -x '"\e[A": __fzf_history__'

  # initialize fzf
  eval "$(fzf --bash)"
fi

if [ $(command -v direnv) ]; then
  eval "$(direnv hook bash)"
fi
