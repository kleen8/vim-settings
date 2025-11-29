# NEW: Increase command history buffer
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history

# This block for p10k is correct, leave it at the top
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

# CHANGED: Added 'fzf' to the plugin list
plugins=(
  git
  fzf  # <-- NEW
  zsh-autosuggestions
  zsh-syntax-highlighting
  history
  docker
  ssh-agent
)

# Enable Auto-Completion
autoload -Uz compinit && compinit

# REMOVED: Redundant source lines.
# These plugins are already loaded by the 'plugins' array above.
# source ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# source ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

source $ZSH/oh-my-zsh.sh

alias gs='git status'
alias ll='ls -lsa'
alias vim='nvim .'
alias k='kubectl'


# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

export PATH=$PATH:$(go env GOPATH)/bin
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
export GOPRIVATE=dev.azure.com
export EDITOR='nvim'

ZSH_HIGHLIGHT_STYLES[command]='fg=blue'
ZSH_HIGHLIGHT_STYLES[path]='fg=cyan,underline'
ZSH_HIGHLIGHT_STYLES[string]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[comment]='fg=bright-black,italic'
ZSH_HIGHLIGHT_STYLES[default]='fg=white'
ZSH_HIGHLIGHT_STYLES[function]='fg=green,bold'

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /opt/homebrew/bin/mc mc
