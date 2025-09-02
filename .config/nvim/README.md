# Neovim configuration
This is my personal neovim configuration with a ``setup.sh`` script to install all needed tools on the machine I am running

## Lsp
In order to modify any of the lsp server configuration use:

``` lua
vim.lsp.config("lsp_provider", {settings = "new_setting"})
```
