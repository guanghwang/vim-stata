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
with open('/tmp/stata-exec_code', 'r') as file:
  filedata = file.read()

# Replace the target string
import re
# The original regex is from kylebarron/stata-exec
# modified for python3
# break down of regex
# first part:keep
# (([\"\'])(?:\\[\s\s]|.)*?\2|(?:[^\w\s]|^)\s*/(?![*/])(?:\\.|\[(?:\\.|.)\]|.)*?/(?=[gmiy]{0,4}\s*(?![*/])(?:\w|$))
# part a
# ([\"\'])(?:\\[\s\s]|.)*?\2
# part b
# (?:[^\w\s]|^)\s*/(?![*/])(?:\\.
# part c
# \[(?:\\.|.)\]|.)*?/(?=[gmiy]{0,4}\s*(?![*/])(?:\w|$)
# second to fourth part: remove
# ///.*?\r?\n\s*
# remove default delimiter ///
# //.*?[$\n]
# remove inline comments
# /\*[\s\s]*?\*/
# remove block comments
filedata = re.sub(
        r"(([\"\'])(?:\\[\s\s]|.)*?\2|(?:[^\w\s]|^)\s*/(?![*/])(?:\\.|\[(?:\\.|.)\]|.)*?/(?=[gmiy]{0,4}\s*(?![*/])(?:\w|$)))|///.*?\r?\n\s*|//.*?[$\n]|/\*[\s\s]*?\*/", 
        r"\1",
        filedata
        )
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
 
