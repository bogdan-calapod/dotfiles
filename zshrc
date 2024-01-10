source $HOME/repos/misc/dotfiles/credentials.env

# Enable vim mode
bindkey -v

# If you come from bash you might have to change your $PATH.
export PATH=$HOME/.local/bin:/usr/local/bin:/snap/bin:$PATH
### Aliases

if [[ $(grep -i Microsoft /proc/version) ]]; then
	export BROWSER=wslview
fi

export PATH_TO_CODA_REPOS="$HOME/repos/coda"
export PATH_TO_DEVOPS_TOOLS="$PATH_TO_CODA_REPOS/devops-tools"
export PATH_TO_FOOTPRINT_CORE="$PATH_TO_CODA_REPOS/footprint-core"

# ------------------------- ­ƒîì Environment Variables ------------------------- #
GPG_TTY=$(tty)
export GPG_TTY

export PYTHONPATH="$PATH_TO_CODA_REPOS/footprint-core/back/"

export FOOTPRINT_DEPLOY_ENV=develop-
# Confluence/Mark token
export JIRA_BROWSER=/usr/bin/wslview
export FOOTPRINT_PDF_GENERATOR_SERVICE="localhost:3010"

export MYSQL_DATABASE='asgard_dev'
export MYSQL_USER='heimdall'
export MYSQL_PASSWORD='root'

export RABBITMQ_AMQP_PORT=5672
export RABBITMQ_MANAGEMENT_PORT=15672
export RABBITMQ_SERVER=192.100.0.2
export RABBITMQ_DEFAULT_VHOST=footprint-vhost-1
export RABBITMQ_DEFAULT_USER=muie
export RABBITMQ_DEFAULT_PASS=rabbit

export FP_DISABLE_COMMITIZEN=true

# ---------------------------------------------------------------------------- #
#                                  ­ƒôü Aliases                                  #
# ---------------------------------------------------------------------------- #
alias pip=pip3
alias adb='/mnt/c/platform-tools/adb.exe'
alias python=python3
alias start-osx='docker run -it --device /dev/kvm -p 50922:10022 -v /tmp/.X11-unix:/tmp/.X11-unix -e "DISPLAY=${DISPLAY:-:0.0}" -e GENERATE_UNIQUE=true sickcodes/docker-osx:auto'
alias ytui="$HOME/.local/bin/ytui_music-linux-amd64"
alias ovftool='/usr/bin/vmware-ovftool/ovftool'
alias wifipass='powershell.exe "Show-WiFiPassword"'
which apt-get &>/dev/null && { alias bat='batcat' }
# alias ncspot='ncspot.exe'
alias fixtime='sudo wslact time-sync'

# ------------------------------ ­ƒî▓ Git Aliases ------------------------------ #
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

### Customizations

# ­ƒöæ SSH Agent Key config
source /tmp/ssh-agent >/dev/null 2>&1
ssh-add 2>/dev/null
if [ $? -ne 0 ]; then
	ssh-agent >/tmp/ssh-agent
	source /tmp/ssh-agent >/dev/null 2>&1
	ssh-add 2>/dev/null
fi
source $PATH_TO_CODA_REPOS/devops-tools/coda-rc/.coda-rc

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
# VI_MODE_SET_CURSOR=true
# VI_MODE_RESET_PROMPT_ON_MODE_CHANGE=true

# ZSH_TMUX_AUTOSTART=true

plugins=(git virtualenv colorize docker node npm timewarrior zsh-yarn-completions tmux zsh-syntax-highlighting zsh-autosuggestions)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# To customize prompt, run `p10k confgit clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
# source ~/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

## Tools ##

# Load LS with Git - https://github.com/gerph/ls-with-git-status
alias ls="$HOME/repos/misc/dotfiles/tools/lsgit.sh"
