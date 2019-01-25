## Vim Plugin for Running Selected Do-File in Stata on Linux
This plugin is inspired by the original [vim-stata](https://github.com/zizhongyan/vim-stata) on mac and atom plugin [stata-exec](https://github.com/kylebarron/stata-exec). The program of sending code to stata is modified from `stata-exec` and the template of vim plugin is from `vim-stata`.

## Install `vim-stata` on Linux
For `junegunn/vim-plug` users, add

```
Plug 'guanghwang/vim-stata', { 'branch': 'linux', 'for': 'stata'}  "stata exec
```

Also,` xdotool` and `xclip` are needed for this plugin to work.


## How to use
1. open stata-gui
2. press `F9` to send selected code to `stata`.
