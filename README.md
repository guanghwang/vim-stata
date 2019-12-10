## Vim Plugin for Running Selected Do-File in Stata on Linux
This plugin is inspired by the original [vim-stata](https://github.com/zizhongyan/vim-stata) on mac and atom plugin [stata-exec](https://github.com/kylebarron/stata-exec). The program of sending code to stata is modified from `stata-exec` and the template of vim plugin is from `vim-stata`.

## Install `vim-stata` on Linux (xwindows)
For `junegunn/vim-plug` users, add

```
Plug 'guanghwang/vim-stata', { 'branch': 'linux', 'for': 'stata'}  "stata exec
```
to `.vimrc`

For `swaywm` user, try the sway branch, it is hard-coded to app_id termite and workspace 5. Feel free to modify the code.

```
Plug 'guanghwang/vim-stata', { 'branch': 'sway', 'for': 'stata'}  "stata exec
```

Also,` xdotool` and `xclip` are needed for this plugin to work under xwindows and `xdotool` is needed for this plugin to work in `sway`.


## How to use
1. open stata-gui
2. press `F9` to send selected code to `stata`.
