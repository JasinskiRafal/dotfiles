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

ctrl-right-subword() {
  local buf="$RBUFFER"
  local n=${#buf}
  local i=1
  # skip any non-letters right at the cursor (e.g. punctuation, spaces)
  while (( i <= n )) && [[ "${buf:$((i-1)):1}" != [[:alpha:]] ]]; do
    (( i++ ))
  done
  # skip letters until we hit the next non-letter
  while (( i <= n )) && [[ "${buf:$((i-1)):1}" == [[:alpha:]] ]]; do
    (( i++ ))
  done
  CURSOR=$(( CURSOR + i - 1 ))
}
zle -N ctrl-right-subword

# Ctrl+Left: jump backward to previous non-letter boundary
ctrl-left-subword() {
  local buf="$LBUFFER"
  local n=${#buf}
  local i=n
  while (( i >= 1 )) && [[ "${buf:$((i-1)):1}" != [[:alpha:]] ]]; do
    (( i-- ))
  done
  while (( i >= 1 )) && [[ "${buf:$((i-1)):1}" == [[:alpha:]] ]]; do
    (( i-- ))
  done
  CURSOR=$i
}
zle -N ctrl-left-subword

# For Home key
bindkey "^[[H" beginning-of-line
# For End key
bindkey "^[[F" end-of-line

# Ctrl+Arrow -> subword jump
bindkey ";5C" ctrl-right-subword
bindkey ";5D" ctrl-left-subword

# Shift+Ctrl+Arrow -> full word jump (your original behavior)
bindkey ";6C" forward-word
bindkey ";6D" backward-word

# If not running interactively, don't do anything
[[ -o interactive ]] || return

source "$HOME/.zshaliases"
source "$HOME/.zshenv"

# Cargo (Rust)
. "$HOME/.cargo/env"

# Starship
eval "$(starship init zsh)"
