# Neovim configuration
This is my personal neovim configuration

## Dependencies
- wget
- git
- unzip
- curl
- ghostscript
- ripgrep
- fd-find
- luarocks
- bear
- python3
- python3-venv
- pip
- lazygit
- viu
- nvm (curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash)
- node (nvm install node)
- node-nvim (npm install -g neovim)

## Lsp
In order to modify any of the lsp server configuration use:

``` lua
vim.lsp.config("lsp_provider", {settings = "new_setting"})
```

## CodeCompanion
In order to use code companion you have to define `MISTRAL_API_KEY` environment variable
