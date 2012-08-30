#!/bin/bash

grep '\/home\/' $1 > $1.name 
grep 'Diffs' $1 >$1.diffs
grep 'Maxdiff' $1 >$1.max
grep 'Sum' $1 >$1.sum
grep 'Average' $1 >$1.average
echo " Dir, Diffs, Max, Average are put in log.*"

