#!/bin/bash 

count=0
while read line           
do           
	IFS=$' \t\n' read -r f1 f6 f7 f8<<<"$line"
	line1=`grep $f1 VM_monitor.log | tail -1`
	IFS=, read -r f9 f2 f3<<<"$line1"
	# Rounding off the percentage values.
	f2=`echo $f2|awk '{print int($1+0.5)}'`
	f3=`echo $f3|awk '{print int($1+0.5)}'`
	actualcoreusage=0
	((actualcoreusage=$f2*$f6/100))
	echo "$f2 $f3"
	((count++))
	if [ $run = "1" ]; then
		echo "First run"
	else
		for ((i=1; i<=n1; i++)) 
		{
			if [ "${vm1[$i]}" = "$f1" ]; then
				cpucompare=`echo "${cpu1[$i]} > 80" | bc`
				echo "cpucompare = $cpucompare"
				if [ $cpucompare -ne 0 ]; then
					cpucompare1=`echo "$f2 > 80" | bc`
					if [ $cpucompare1 -ne 0 ]; then
						CPU=`grep -m 1 $f1 Node1Load | awk {'print $2'}`
						MEMORY=`grep -m 1 $f1 Node1Load | awk {'print $4'}`
						((CPU++))
						((MEMORY=MEMORY-128))
						((MEMORY=MEMORY*1024))
						./DecisionAlgo.sh "node1" $CPU $MEMORY $f1
					fi
				fi
				memcompare=`echo "${mem1[$i]} > 20" | bc`
				if [ $memcompare -ne 0 ]; then
					memcompare=`echo "$f3 > 20" | bc`
					if [ $memcompare -ne 0 ]; then
						CPU=`grep -m 1 $f1 Node1Load | awk {'print $2'}`
						MEMORY=`grep -m 1 $f1 Node1Load | awk {'print $4'}`
						((MEMORY=MEMORY*1024))
						./DecisionAlgo.sh "node1" $CPU $MEMORY $f1
					fi
				fi
				memcompare=`echo "${mem1[$i]} < 10" | bc`
				if [ $memcompare -ne 0 ]; then
					memcompare=`echo "$f3 < 10" | bc`
					if [ $memcompare -ne 0 ]; then
						CPU=`grep -m 1 $f1 Node1Load | awk {'print $2'}`
						MEMORY=`grep -m 1 $f1 Node1Load | awk {'print $4'}`
						((MEMORY=MEMORY-306))
						((MEMORY=MEMORY*1024))
						./DecisionAlgo.sh "node1" $CPU $MEMORY $f1
					fi
				fi
			count=$i
			break
			else
			count=$i
			((count++))
			fi
		}		
	fi
	cpu1[$count]=$f2
	mem1[$count]=$f3
	vm1[$count]=$f1
	
done < Node1Load
n1=count
count=0
while read line           
do           
	IFS=$' \t\n' read -r f1 f6 f7 f8<<<"$line"
	line1=`grep $f1 VM_monitor.log | tail -1`
	IFS=, read -r f9 f2 f3<<<"$line1"
	echo "$f2 $f3"
	((count++))
	if [ $run = "1" ]; then
		echo "First run"
	else
		for ((i=1; i<=n2; i++)) 
		{
			if [ "${vm1[$i]}" = "$f1" ]; then
				cpucompare=`echo "${cpu1[$i]} > 80" | bc`
				echo "cpucompare = $cpucompare"
				if [ $cpucompare -ne 0 ]; then
					cpucompare1=`echo "$f2 > 80" | bc`
					if [ $cpucompare1 -ne 0 ]; then
						CPU=`grep -m 1 $f1 Node2Load | awk {'print $2'}`
						MEMORY=`grep -m 1 $f1 Node2Load | awk {'print $4'}`
						((CPU++))
						((MEMORY=MEMORY-128))
						((MEMORY=MEMORY*1024))
						./DecisionAlgo.sh "node2" $CPU $MEMORY $f1
					fi
				fi
				memcompare=`echo "${mem1[$i]} > 20" | bc`
				if [ $memcompare -ne 0 ]; then
					memcompare=`echo "$f3 > 20" | bc`
					if [ $memcompare -ne 0 ]; then
						CPU=`grep -m 1 $f1 Node2Load | awk {'print $2'}`
						MEMORY=`grep -m 1 $f1 Node2Load | awk {'print $4'}`
						((MEMORY=MEMORY*1024))
						./DecisionAlgo.sh "node2" $CPU $MEMORY $f1
					fi
				fi
				memcompare=`echo "${mem1[$i]} < 10" | bc`
				if [ $memcompare -ne 0 ]; then
					memcompare=`echo "$f3 < 10" | bc`
					if [ $memcompare -ne 0 ]; then
						CPU=`grep -m 1 $f1 Node2Load | awk {'print $2'}`
						MEMORY=`grep -m 1 $f1 Node2Load | awk {'print $4'}`
						((MEMORY=MEMORY-306))
						((MEMORY=MEMORY*1024))
						./DecisionAlgo.sh "node2" $CPU $MEMORY $f1
					fi
				fi
			count=$i
			break
			else
			count=$i
			((count++))
			fi
		}		
	fi
	cpu1[$count]=$f2
	mem1[$count]=$f3
	vm1[$count]=$f1
	
done < Node2Load
n2=count
sleep 10

