#!/bin/bash

line_count=0
while read line;
do
	U="_"
	IFS=, read -r f2 f3 f4 f5 f6 f7<<<"$line"
	newvm=${f3}${U}${f4}${U}${f5}
	echo $newvm
	COUNT1=$(grep -c "$newvm" Node1Load)
	COUNT2=$(grep -c "$newvm" Node2Load)
	COUNT3=$(grep -c "$newvm" Node3Load)
	COUNT=$(($COUNT1 + $COUNT2 + $COUNT3))
	line_count=$(($line_count + 1))
	echo $COUNT 	
	if [[ $COUNT -eq 0 ]]
	then
 		./VM_submitjob.sh $newvm ${f6} ${f7} 
		sleep 100 #& echo "Finished submit job"
	else
		if [[ $COUNT1 -ge 1 ]]; then
			./DecisionAlgo.sh "node1" ${f6} ${f7} $newvm
			sleep 100
		elif [[ $COUNT2 -ge 1 ]]; then
			./DecisionAlgo.sh "node2" ${f6} ${f7} $newvm
			sleep 100
		else
			./DecisionAlgo.sh "node3" ${f6} ${f7} $newvm
			sleep 100
		fi
	fi
	#echo "Line Count: " $line_count
	#if [[ $line_count -eq 1 ]]
	#then
	#	sleep 600
	#	line_count=0
	#fi
done < Alloc1
