#
# ~/.zshrc
#

# The following lines were added by compinstall
zstyle :compinstall filename "$HOME/.zshrc"

autoload -Uz compinit
compinit
# End of lines added by compinstall
# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000

# For Home key
bindkey "^[[H" beginning-of-line
# For End key
bindkey "^[[F" end-of-line

# For ctrl + right arrow
bindkey ";5C" forward-word

# For ctrl + left arrow
bindkey ";5D" backward-word

# If not running interactively, don't do anything
[[ -o interactive ]] || return

# Aliases
alias ls='ls --color=auto'
alias grep='grep --color=auto'

source "$HOME/.zshaliases"
source "$HOME/.zshenv"

# Cargo (Rust)
. "$HOME/.cargo/env"

# Starship
eval "$(starship init zsh)"
