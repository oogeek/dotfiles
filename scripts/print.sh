#!/bin/bash
file="$1"
name=${file%.*}
enscript --line-numbers --header='$n %W Page $% of $='-Ebash -p "$name.ps" -w PostScript "$file"
# enscript --header='$n|%W|Page $% of $=' --line-numbers -p "$name.ps" "$file"
ps2pdf "$name.ps"
pwd
