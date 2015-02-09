#!/bin/bash           

#echo | awk -v r=$root '{ print "shell root value - " r}'

while read line           
do           
	IFS=, read -r f1 f2 f3 f4 f5 f6<<<"$line"
	#echo "$line"
	BASEMEM=262144
	echo $f6
	MEM=$(($BASEMEM+$f6))
	./simulation.sh $f5 $MEM &
	nPid=`ps -ef|grep "stress"|grep -v "grep"|awk '{print $2}'`;
	sleep $f1
	kill -9 $nPid
done < $1

