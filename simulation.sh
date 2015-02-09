#!/bin/bash

cpu=$1
mem=$2


if [[ $cpu -ge 1 && $cpu -lt 2 ]]; then
	a=10
elif [[ $cpu -eq 3 ]]; then
	a=20
elif [[ $cpu -eq 4 ]]; then
	a=30
fi


if [[ $mem -ge 262144 && $mem -lt 409600 ]]; then
	b=10
elif [[ $mem -ge 410624 && $mem -lt 614400 ]]; then
	b=20
elif [[ $mem -ge 615424 && $mem -lt 1048576 ]]; then
	b=30
fi


n=$((1500+$a+$b))
echo $n
m=$((1500+$a+$b))
echo $m
./stress5b.sh $n $m
