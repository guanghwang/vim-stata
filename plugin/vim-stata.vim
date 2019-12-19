" Vim to Stata  
"==============================================================================
"Script Description: Run selected do-file in Stata from Vim
"Script Platform: Linux Swaywm and Stata 14, 15
"Script Version: 0.02
"Last Edited: Dec 19, 2019
"Authors:  Guanghua Wang
"Notes:
"   1. This plugin is motivated by zizhongyan/vim-stata and kylebarron/stata-exec
"   2. This plugin only workers on Linux.
"   3. `xdotool` and `wl-clipboard` are needed for this plugin to work
"==============================================================================

fun! RunDoLines()
let selectedLines = getbufline('%', line("'<"), line("'>"))
if col("'>") < strlen(getline(line("'>")))
let selectedLines[-1] = strpart(selectedLines[-1], 0, col("'>"))
endif
if col("'<") != 1
let selectedLines[0] = strpart(selectedLines[0], col("'<")-1)
endif
call writefile(selectedLines, "/tmp/stata-exec_code")
python3 << EOF
import vim
import sys
import os
import re
with open('/tmp/stata-exec_code', 'r') as file:
    filedata = file.read()
# 1. remove /*    */
filedata = re.sub(r'\/\*[\s\S]*?\*\/', r"", filedata)
# 2. remove ///
filedata = re.sub(r'(/){3}.*?(\r\n|\r|\n)', r"", filedata)
# 3. remove //coments
filedata = re.sub(r'(/){2}.*?(\r\n|\r|\n)', r"\2", filedata)
with open('/tmp/stata-exec_code', 'w') as file:
    file.write(filedata)
# send codes to stata
# match the app_id and workspace
# it works if there is only one instance of the editor in the focused workspace
def run_yan():
    cmd = ("""
           thiswks="$(swaymsg -t get_workspaces | jq '.[] \
             | select(.focused==true) | .num')" &&
           thiswindow="$(swaymsg -t get_tree | jq '.. \
             | (.nodes? // empty)[] | select(.focused==true) | .app_id')" &&
           wl-copy -c &&
           cat /tmp/stata-exec_code | wl-copy &&
           swaymsg '[title="[Ss]tata.*"] focus' &&
           xdotool \
             key --clearmodifiers --delay 100 ctrl+v Return &&
           swaymsg '[app_id='$thiswindow' workspace='$thiswks'] focus' &&
           wl-copy -c
           """
           )
    os.system(cmd)
run_yan()
EOF
endfun

noremap  <Plug>(RunDoLines)            :<C-U>call RunDoLines()<CR><CR>
map  <buffer> <silent> <F9>          <Plug>(RunDoLines)
"command! Vim2StataToggle call RunDoLines()<CR><CR>
