# Disable Oh My Zsh auto update
DISABLE_AUTO_UPDATE=true

# Ignore insecure completion-dependent directories
ZSH_DISABLE_COMPFIX=true

# Disable magic functions so that URLs paste properly
DISABLE_MAGIC_FUNCTIONS=true

# Set history file
export HISTFILE=~/.zsh_history

# Source shared environment
source ~/.sharedrc

# Configure history
setopt appendhistory
setopt sharehistory
setopt incappendhistory
setopt histIgnoreSpace

# gcloud
if [ -x "$(command -v brew)" ]; then
    if [ -f "$(brew --prefix)/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc" ]; then
        source "$(brew --prefix)/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc"
    fi
fi

# Homebrew zsh completion
if [ -x "$(command -v brew)" ]; then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
  autoload -Uz compinit
  compinit -u
fi

# 1password cli zsh completion
if [ -x "$(command -v op)" ]; then
  eval "$(op completion zsh)"; compdef _op op
fi

# Activate Shad's zsh git prompt
source "$HOME/.zsh-git-prompt/git-prompt.zsh"

# Path to oh-my-zsh installation
export ZSH=$HOME/.oh-my-zsh

# Set oh-my-zsh theme
ZSH_THEME="shad"

if [ $(zsh --version | cut -d' ' -f2 | cut -d'.' -f1) -gt "4" ]; then
	plugins+=(zsh-syntax-highlighting)
fi

# Activate oh-my-zsh
source $ZSH/oh-my-zsh.sh

notify() {
  local exit_status=$?
  local -a stats=( $(fc -Dl -1) )

  local -a time=( "${(s.:.)stats[2]}" )
  local -i seconds=0 mult=1
  while (( $#time[@] )); do
    (( seconds += mult * time[-1] ))
    (( mult *= 60 ))
    shift -p time
  done

  if (( seconds >= 120 )); then
    local emoji=$([ $exit_status -ne 0 ] && echo "❌" || echo "✅")
    local exits=$([ $exit_status -ne 0 ] && echo "failed" || echo "succeeded")
    local msg="${emoji} \`${stats[3,-1]}\` _${exits}_ after *${stats[2]}* on __$(whoami)@$(hostname -s)__"
    telegram "$msg"
  fi

  return 0
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd notify

# Enable Ctrl-x-e to edit command line
autoload -U edit-command-line
zle -N edit-command-line
bindkey '^x^e' edit-command-line

# Configure venv
export VIRTUAL_ENV_DISABLE_PROMPT=0

# Enable command-line fuzzy finder (https://github.com/junegunn/fzf)
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Source local shared environment
if [ -f "$HOME/.sharedenv" ]; then
	source "$HOME/.sharedenv"
fi

# Source local zsh environment
if [ -f "$HOME/.zshenv" ]; then
	source "$HOME/.zshenv"
fi
