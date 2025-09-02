Use stow to symlink dotfiles to the home directory
```bash
stow .
```

In order to use the `.bashrc-raj`, put this at the end of your `.bashrc`
```bash
if [ -f ~/.bashrc-raj ]; then
    . ~/.bashrc-raj
fi
```
