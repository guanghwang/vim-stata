" Vim to Stata  
"==============================================================================
"Script Description: Run selected do-file in Stata from Vim
"Script Platform: Linux and Stata 14, 15
"Script Version: 0.01
"Last Edited: Jan 24, 2019
"Authors:  Guanghua Wang
"Notes:
"   1. This plugin is motivated by zizhongyan/vim-stata and kylebarron/stata-exec
"   2. This plugin only workers on Linux.
"   3. `xdotool` and `xclip` are needed for this plugin to work
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
# 2. remove //coments
filedata = re.sub(r'\/\/.*?(\r\n|\r|\n)', r"", filedata)
# 3. remove ///
filedata = re.sub(r'\/\/\/.*?(\r\n|\r|\n)', r"", filedata)
with open('/tmp/stata-exec_code', 'w') as file:
  file.write(filedata)
# send codes to stata
def run_yan():
    cmd = ("""
           old_cb="$(xclip -o -selection clipboard)";
           this_window="$(xdotool getactivewindow)" &&
           stata_window="$(xdotool search --name --limit 1 "stata/(ic|se|mp)? 1[0-9]\.[0-9]")" &&
           cat /tmp/stata-exec_code | xclip -i -selection clipboard &&
           xdotool \
             keyup ctrl shift \
             windowactivate --sync $stata_window \
             key --clearmodifiers --delay 100 ctrl+v Return \
             windowactivate --sync $this_window;
           printf "$old_cb" | xclip -i -selection clipboard
           """
           )
    os.system(cmd)
run_yan()
EOF
endfun

noremap  <Plug>(RunDoLines)            :<C-U>call RunDoLines()<CR><CR>
map  <buffer> <silent> <F9>          <Plug>(RunDoLines)
"command! Vim2StataToggle call RunDoLines()<CR><CR>
 
