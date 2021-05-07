#!/bin/bash
find "$(pwd)" -xtype l > broken
while IFS= read -r file
do
    echo "$file"
   unlink  "$file"
   #rm -iv "$file"
done < broken
