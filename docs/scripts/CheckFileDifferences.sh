#!/bin/bash

# Check if two arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <directory1> <directory2>"
    exit 1
fi

DIR1="$1"
DIR2="$2"

find "$DIR1" -type f | while read -r file; do
    file_in_dir2="${file/$DIR1/$DIR2}"

    if [ -f "$file_in_dir2" ]; then
        if ! diff -q "$file" "$file_in_dir2" > /dev/null; then
            echo "Files Differ: $file and $file_in_dir2"
        else
            echo "Files Match: $file and $file_in_dir2"
        fi
    else
        echo "File missing in $DIR2: $file_in_dir2"
    fi
done
