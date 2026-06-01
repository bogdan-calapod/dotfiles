#
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

# # 🔑 SSH
source /tmp/ssh-agent >/dev/null 2>&1
ssh-add 2>/dev/null
if [ $? -ne 0 ]; then
	ssh-agent >/tmp/ssh-agent
	source /tmp/ssh-agent >/dev/null 2>&1
	ssh-add 2>/dev/null
fi
source $PATH_TO_CODA_REPOS/devops-tools/coda-rc/.coda-rc

# Node version management is handled by mise (see ~/.zshrc).

# ⚡️ ZSH Config — sensible defaults (replaces oh-my-zsh)

# History
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=10000
setopt extended_history       # save timestamps
setopt hist_expire_dups_first # trim oldest dup first
setopt hist_ignore_dups       # don't record consecutive dups
setopt hist_ignore_space      # leading-space commands aren't saved
setopt hist_verify            # show expansion before running
setopt share_history          # share history across sessions
setopt inc_append_history     # append immediately, not on exit

# Directory navigation
setopt auto_cd                # `dirname` == `cd dirname`
setopt auto_pushd             # cd pushes to dir stack
setopt pushd_ignore_dups
setopt pushd_silent
alias -- -='cd -'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Misc
setopt interactive_comments   # allow `# comments` in interactive shell
setopt long_list_jobs         # verbose `jobs` output
setopt no_beep
setopt no_flow_control        # free up Ctrl-S / Ctrl-Q

# Plugins (sourced from ~/.config/zsh/plugins, which symlinks here)
ZSH_PLUGINS="$HOME/.config/zsh/plugins"
source "$ZSH_PLUGINS/zsh-autosuggestions/zsh-autosuggestions.zsh"
# syntax-highlighting must be sourced LAST among shell plugins
source "$ZSH_PLUGINS/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

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


eval "$(atuin init zsh --disable-up-arrow)"

# Add tmux pane rename
ssh() {
    if [ "$(ps -p $(ps -p $$ -o ppid=) -o comm=)" = "tmux" ]; then
        tmux select-pane -T "$(echo $* | cut -d . -f 1)"
        command ssh "$@"
        tmux set-window-option automatic-rename "on" 1>/dev/null
    else
        command ssh "$@"
    fi
}


eval "$(starship init zsh)"
