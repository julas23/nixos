setopt nonomatch
setopt correct
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="julas23"
plugins=(git)
source $ZSH/oh-my-zsh.sh

# History improvement
HIST_IGNORE=(cmd fgrep egrep)
HISTSIZE=1000000
HISTFILE=~/.zsh_history
HIST_STAMPS="%d/%m %T $(whoami)"
setopt histappend

[ ! -x /usr/bin/yay ] && [ -x /usr/bin/paru ] && alias yay='paru'
USE_POWERLINE="true"
HAS_WIDECHARS="false"

source ~/.aliasrc
