#!/bin/bash

SourceNode=$1
CPUreq=$2
MemReq=$((262144 + $3))
#MemReq=$3
VMname=$4

echo "started DecisionAlgo.sh"
#echo $SourceNode
#echo $CPUreq
echo $MemReq
#echo $VMname

NODE2CPU=`awk '{sum+=$2} END {print sum}' /home/masternode/scripts/Node2Load`
NODE3CPU=`awk '{sum+=$2} END {print sum}' /home/masternode/scripts/Node3Load`
NODE1CPU=`awk '{sum+=$2} END {print sum}' /home/masternode/scripts/Node1Load`
ONEKB=1024

NODE1MEM_MB=`awk '{sum+=$4} END {print sum}' /home/masternode/scripts/Node1Load`
if [ "$NODE1MEM_MB" = "" ]
then
	NODE1MEM_MB=0
else
	NODE1MEM=$(($NODE1MEM_MB * $ONEKB))
fi

NODE2MEM_MB=`awk '{sum+=$4} END {print sum}' /home/masternode/scripts/Node2Load`
if [ "$NODE2MEM_MB" = "" ]
then
	NODE2MEM_MB=0
else
	NODE2MEM=$(($NODE2MEM_MB * $ONEKB))
fi

NODE3MEM_MB=`awk '{sum+=$4} END {print sum}' /home/masternode/scripts/Node3Load`
if [ "$NODE3MEM_MB" = "" ]
then
	NODE3MEM_MB=0
else
	NODE3MEM=$(($NODE3MEM_MB * $ONEKB))
fi

MAX=8 #to be changed as per requirement
MEM_THRESHOLD=7340032 #For Migration
MAX_MEM=1048576

if [ "$SourceNode" = "node1" ]
then
	Maxcpu=`ssh node1@192.168.1.105 virsh vcpucount $VMname | tail -n 4 | awk '{print $3}' | head -n 1`
	Count=`ssh node1@192.168.1.105 virsh vcpucount $VMname | tail -n 2 | awk '{print $3}' | head -n 1`
	CurMem=`ssh node1@192.168.1.105 virsh dominfo $VMname | grep ^Used | awk '{print $3}'`
	#VM_MEM_COUNT=`ssh node1@192.168.1.105 virsh dominfo $VMname | grep "^Used" | awk -F'[:\\s\t]' '{print $3}' | awk '{print $1}'`
elif [ "$SourceNode" = "node2" ]
then
	#echo "inside node2"
	Maxcpu=`ssh node2@192.168.1.106 virsh vcpucount $VMname | tail -n 4 | awk '{print $3}' | head -n 1`
	#echo $Maxcpu
	Count=`ssh node2@192.168.1.106 virsh vcpucount $VMname | tail -n 2 | awk '{print $3}' | head -n 1`
	CurMem=`ssh node2@192.168.1.106 virsh dominfo $VMname | grep ^Used | awk '{print $3}'`
	#echo $Count
	#VM_MEM_COUNT=`ssh node2@192.168.1.106 virsh dominfo $VMname | grep "^Used" | awk -F'[:\\s\t]' '{print $3}' | awk '{print $1}'`
else
	Maxcpu=`ssh node3@192.168.1.108 virsh vcpucount $VMname | tail -n 4 | awk '{print $3}' | head -n 1`
	Count=`ssh node3@192.168.1.108 virsh vcpucount $VMname | tail -n 2 | awk '{print $3}' | head -n 1`
	CurMem=`ssh node3@192.168.1.108 virsh dominfo $VMname | grep ^Used | awk '{print $3}'`
	#VM_MEM_COUNT=`ssh node3@192.168.1.108 virsh dominfo $VMname | grep "^Used" | awk -F'[:\\s\t]' '{print $3}' | awk '{print $1}'`
fi

CPUchange=$((CPUreq - Count))
echo "Change in CPU: " $CPUchange
echo "Current memory: "$CurMem

#for downscale set cpureq to current cpu
if [[ $CPUchange -lt 0 ]]; then
 $CPUchange=$Count
fi

if [[ $MemReq -gt $MAX_MEM ]]; then
	$MemReq=1048576
fi

Memcomp=$(($MemReq - $CurMem))
echo "Memcomp: " $Memcomp
if [[ $Memcomp -eq 0 ]]; then 
	echo "do nothing"
elif [[ $Memcomp -lt 0 ]]; then
	echo "downscale"
fi

# change -gt to -ge
# does not work for cpu downscale and memory upscaling

#if [ $CPUchange -ge 0 ]; then

if [ $CPUchange -ge 0 ]; then
	if [ "$SourceNode" = "node1" ]; then
		Total=$(($NODE1CPU + $CPUchange))
		EXPECTEDMEMLOAD=$(($NODE1MEM + $Memcomp))
		echo "Expected Mem Load: " $EXPECTEDMEMLOAD
		if [[ $Total -lt $MAX && $EXPECTEDMEMLOAD -lt $MEM_THRESHOLD ]]; then
		./VM_Scaling.sh "node1" $VMname $CPUreq $Count $MemReq
		else
		./VM_Migration.sh $VMname "node1" $Count $Maxcpu $MemReq $CPUreq $CurMem
		fi
	elif [ "$SourceNode" = "node2" ]; then
		Total=$(($NODE2CPU + $CPUchange))
		EXPECTEDMEMLOAD=$(($NODE2MEM + $Memcomp))
		echo "Expected Mem Load: " $EXPECTEDMEMLOAD
		if [[ $Total -lt $MAX && $EXPECTEDMEMLOAD -lt $MEM_THRESHOLD ]]; then
		./VM_Scaling.sh "node2" $VMname $CPUreq $Count $MemReq
		else
		./VM_Migration.sh $VMname "node2" $Count $Maxcpu $MemReq $CPUreq $CurMem
		fi
	else
		Total=$(($NODE3CPU + $CPUchange))
		EXPECTEDMEMLOAD=$(($NODE3MEM + $Memcomp))
		echo "Expected Mem Load: " $EXPECTEDMEMLOAD
		if [[ $Total -lt $MAX && $EXPECTEDMEMLOAD -lt $MEM_THRESHOLD ]]; then
		./VM_Scaling.sh "node3" $VMname $CPUreq $Count $MemReq
		else
		./VM_Migration.sh $VMname "node3" $Count $Maxcpu $MemReq $CPUreq $CurMem
		fi
	fi
fi
echo "Done Decision"
