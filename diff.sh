#!/bin/bash

for file in $(cat filelist)
do
    echo $file
    dir1="$1/$file"
    dir2="$2/$file"
    echo "$dir1   :   $dir2"
    #echo "file2 = $dir2 "
    num=`ls -l $dir1  |awk '{printf $5}'`
    num=$(( $num /4))
    ./hytest $num  $dir1 $dir2 
done

