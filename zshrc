source $HOME/repos/misc/dotfiles/credentials.env

# Starship RS Config
# ZSH has a quirk where `preexec` is only run if a command is actually run (i.e
# pressing ENTER at an empty command line will not cause preexec to fire). This
# can cause timing issues, as a user who presses "ENTER" without running a command
# will see the time to the start of the last command, which may be very large.

# To fix this, we create STARSHIP_START_TIME upon preexec() firing, and destroy it
# after drawing the prompt. This ensures that the timing for one command is only
# ever drawn once (for the prompt immediately after it is run).

zmodload zsh/parameter  # Needed to access jobstates variable for STARSHIP_JOBS_COUNT

# Defines a function `__starship_get_time` that sets the time since epoch in millis in STARSHIP_CAPTURED_TIME.
if [[ $ZSH_VERSION == ([1-4]*) ]]; then
    # ZSH <= 5; Does not have a built-in variable so we will rely on Starship's inbuilt time function.
    __starship_get_time() {
        STARSHIP_CAPTURED_TIME=$(/usr/local/bin/starship time)
    }
else
    zmodload zsh/datetime
    zmodload zsh/mathfunc
    __starship_get_time() {
        (( STARSHIP_CAPTURED_TIME = int(rint(EPOCHREALTIME * 1000)) ))
    }
fi

# The two functions below follow the naming convention `prompt_<theme>_<hook>`
# for compatibility with Zsh's prompt system. See
# https://github.com/zsh-users/zsh/blob/2876c25a28b8052d6683027998cc118fc9b50157/Functions/Prompts/promptinit#L155

# Runs before each new command line.
prompt_starship_precmd() {
    # Save the status, because subsequent commands in this function will change $?
    STARSHIP_CMD_STATUS=$? STARSHIP_PIPE_STATUS=(${pipestatus[@]})

    # Calculate duration if a command was executed
    if (( ${+STARSHIP_START_TIME} )); then
        __starship_get_time && (( STARSHIP_DURATION = STARSHIP_CAPTURED_TIME - STARSHIP_START_TIME ))
        unset STARSHIP_START_TIME
    # Drop status and duration otherwise
    else
        unset STARSHIP_DURATION STARSHIP_CMD_STATUS STARSHIP_PIPE_STATUS
    fi

    # Use length of jobstates array as number of jobs. Expansion fails inside
    # quotes so we set it here and then use the value later on.
    STARSHIP_JOBS_COUNT=${#jobstates}
}

# Runs after the user submits the command line, but before it is executed and
# only if there's an actual command to run
prompt_starship_preexec() {
    __starship_get_time && STARSHIP_START_TIME=$STARSHIP_CAPTURED_TIME
}

# Add hook functions
autoload -Uz add-zsh-hook
add-zsh-hook precmd prompt_starship_precmd
add-zsh-hook preexec prompt_starship_preexec

# Set up a function to redraw the prompt if the user switches vi modes
starship_zle-keymap-select() {
    zle reset-prompt
}

## Check for existing keymap-select widget.
# zle-keymap-select is a special widget so it'll be "user:fnName" or nothing. Let's get fnName only.
__starship_preserved_zle_keymap_select=${widgets[zle-keymap-select]#user:}
if [[ -z $__starship_preserved_zle_keymap_select ]]; then
    zle -N zle-keymap-select starship_zle-keymap-select;
else
    # Define a wrapper fn to call the original widget fn and then Starship's.
    starship_zle-keymap-select-wrapped() {
        $__starship_preserved_zle_keymap_select "$@";
        starship_zle-keymap-select "$@";
    }
    zle -N zle-keymap-select starship_zle-keymap-select-wrapped;
fi

export STARSHIP_SHELL="zsh"

# Set up the session key that will be used to store logs
STARSHIP_SESSION_KEY="$RANDOM$RANDOM$RANDOM$RANDOM$RANDOM"; # Random generates a number b/w 0 - 32767
STARSHIP_SESSION_KEY="${STARSHIP_SESSION_KEY}0000000000000000" # Pad it to 16+ chars.
export STARSHIP_SESSION_KEY=${STARSHIP_SESSION_KEY:0:16}; # Trim to 16-digits if excess.

VIRTUAL_ENV_DISABLE_PROMPT=1

setopt promptsubst

PROMPT='$('/usr/local/bin/starship' prompt --terminal-width="$COLUMNS" --keymap="${KEYMAP:-}" --status="$STARSHIP_CMD_STATUS" --pipestatus="${STARSHIP_PIPE_STATUS[*]}" --cmd-duration="${STARSHIP_DURATION:-}" --jobs="$STARSHIP_JOBS_COUNT")'
RPROMPT='$('/usr/local/bin/starship' prompt --right --terminal-width="$COLUMNS" --keymap="${KEYMAP:-}" --status="$STARSHIP_CMD_STATUS" --pipestatus="${STARSHIP_PIPE_STATUS[*]}" --cmd-duration="${STARSHIP_DURATION:-}" --jobs="$STARSHIP_JOBS_COUNT")'
PROMPT2="$(/usr/local/bin/starship prompt --continuation)"

# 🏞️ Environment Variables
export PATH=$HOME/.local/bin:/usr/local/bin:/snap/bin:$PATH

export PATH_TO_CODA_REPOS="$HOME/repos/coda"
export PATH_TO_DEVOPS_TOOLS="$PATH_TO_CODA_REPOS/devops-tools"
export PATH_TO_FOOTPRINT_CORE="$PATH_TO_CODA_REPOS/footprint-core"

GPG_TTY=$(tty)
export GPG_TTY

export PYTHONPATH="$PATH_TO_CODA_REPOS/footprint-core/back/"

export FOOTPRINT_DEPLOY_ENV=develop-

# Confluence/Mark token
export FOOTPRINT_PDF_GENERATOR_SERVICE="localhost:3010"

export MYSQL_DATABASE='asgard_dev'
export MYSQL_USER='heimdall'
export MYSQL_PASSWORD='root'

export RABBITMQ_AMQP_PORT=5672
export RABBITMQ_MANAGEMENT_PORT=15672
export RABBITMQ_SERVER=192.100.0.3
export RABBITMQ_DEFAULT_VHOST=footprint-vhost-1
export RABBITMQ_DEFAULT_USER=guest
export RABBITMQ_DEFAULT_PASS=guest

export FP_DISABLE_COMMITIZEN=true

# Lazy load NVM
export NVM_LAZY_LOAD=true
export NVM_COMPLETION=true

# # 🔑 SSH
source /tmp/ssh-agent >/dev/null 2>&1
ssh-add 2>/dev/null
if [ $? -ne 0 ]; then
	ssh-agent >/tmp/ssh-agent
	source /tmp/ssh-agent >/dev/null 2>&1
	ssh-add 2>/dev/null
fi
source $PATH_TO_CODA_REPOS/devops-tools/coda-rc/.coda-rc

# # 📁 NVM Config
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion


# ⚡️ ZSH Config
export ZSH="$HOME/.oh-my-zsh"

ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"

plugins=(zsh-nvm git virtualenv colorize docker node npm timewarrior zsh-yarn-completions tmux zsh-syntax-highlighting zsh-autosuggestions)

source $ZSH/oh-my-zsh.sh

# WSL-only environment and aliases
if [ -f /proc/version ];  then
  if [[ $(grep -i Microsoft /proc/version) ]]; then
    export JIRA_BROWSER=/usr/bin/wslview
    export BROWSER=wslview
    
    alias ncspotw='ncspot.exe'
    alias adb='/mnt/c/platform-tools/adb.exe'
    alias fixtime='sudo wslact time-sync'
    alias wifipass='powershell.exe "Show-WiFiPassword"'
  fi
fi


# 🎟️ Aliases
alias pip=pip3
alias python=python3
alias ytui="$HOME/.local/bin/ytui_music-linux-amd64"
alias ovftool='/usr/bin/vmware-ovftool/ovftool'
which apt-get &>/dev/null && { alias bat='batcat' }

alias ga='git add'
alias gac='ga .; gc'
alias gacp='gac; gp'
alias gs='git status'
alias gc='git commit'
alias gacfp='gac; gff; gp'
alias gp='git pull --no-edit; git push'
alias gff='HUSKY=0 git checkout develop && gp && git checkout @{-1} && git flow finish'
alias vim='nvim'
alias vi='nvim'

export VISUAL='nvim'
export EDITOR='nvim'

alias ls="eza --git --icons -l"

# For presenterm-export to work
export DYLD_FALLBACK_LIBRARY_PATH=/opt/homebrew/lib:$DYLD_FALLBACK_LIBRARY_PATH

. "$HOME/.atuin/bin/env"

eval "$(atuin init zsh --disable-up-arrow)"
