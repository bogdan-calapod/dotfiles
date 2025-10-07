source $HOME/repos/misc/dotfiles/credentials.env
;
VIRTUAL_ENV_DISABLE_PROMPT=1

setopt promptsubst

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



# eval "$(atuin init zsh --disable-up-arrow)"
