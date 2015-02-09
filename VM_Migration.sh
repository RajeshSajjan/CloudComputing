#!/bin/bash

VMname=$1 
Nodename=$2
Currentcpu=$3 
Maxcpu=$4
Memcur=$5
CPUreq=$6
CurMem=$7

echo " starting Migration"
#echo "CPU requested $CPUreq"

NODE2CPU=`awk '{sum+=$2} END {print sum}' /home/masternode/scripts/Node2Load`
if [ "$NODE2CPU" = "" ]
then
	NODE2CPU=0
fi

NODE3CPU=`awk '{sum+=$2} END {print sum}' /home/masternode/scripts/Node3Load`
if [ "$NODE3CPU" = "" ]
then
	NODE3CPU=0
fi

NODE1CPU=`awk '{sum+=$2} END {print sum}' /home/masternode/scripts/Node1Load`
if [ "$NODE1CPU" = "" ]
then
	NODE1CPU=0
fi

#NODE1MEM=`awk '{sum+=$4} END {print sum}' /home/masternode/scripts/Node1Load`
#NODE1MEM_KiB=$(($NODE1MEM * $ONEKB))
#NODE2MEM=`awk '{sum+=$4} END {print sum}' /home/masternode/scripts/Node2Load`
#NODE2MEM_KiB=$(($NODE2MEM * $ONEKB))
#NODE3MEM=`awk '{sum+=$4} END {print sum}' /home/masternode/scripts/Node3Load`
#NODE3MEM_KiB=$(($NODE3MEM * $ONEKB))
#UNIT="k"
NODE1MEM=`awk '{sum+=$4} END {print sum}' /home/masternode/scripts/Node1Load`
if [ "$NODE1MEM" = "" ]
then
	NODE1MEM=0
fi

NODE2MEM=`awk '{sum+=$4} END {print sum}' /home/masternode/scripts/Node2Load`
if [ "$NODE2MEM" = "" ]
then
	NODE2MEM=0
fi

NODE3MEM=`awk '{sum+=$4} END {print sum}' /home/masternode/scripts/Node3Load`
if [ "$NODE3MEM" = "" ]
then
	NODE3MEM=0
fi

MAX=15 #to be changed as per requirement
MEM_THRESHOLD=7340032 #For Migration
MAX_MEM=1048576
THRESHOLD=11

if [ "$Nodename" = "node1" ]; then
	NODE2IDLE=$(($THRESHOLD - $NODE2CPU))
	NODE3IDLE=$(($THRESHOLD - $NODE3CPU))
	NODE2IDLE_MEM=$(($MEM_THRESHOLD - $NODE2MEM))
	echo "NODE2IDLE_MEM" $NODE2IDLE_MEM
	NODE3IDLE_MEM=$(($MEM_THRESHOLD - $NODE3MEM))
	echo "$NODE3IDLE_MEM"

	if [[ $NODE3IDLE_MEM -gt $NODE2IDLE_MEM && $NODE3IDLE_MEM -gt $Memcur ]]; then
		if [ $NODE3IDLE -ge $CPUreq ]; then
			echo "Migrating from Node 1 to Node 3"
			`ssh node1@192.168.1.105 virsh migrate --live $VMname qemu+ssh://node3@192.168.1.108/system`
			sed -i "/${VMname}/d" /home/masternode/scripts/Node1Load
			echo ""$VMname"	"$Currentcpu"	"$Maxcpu"	"$Memcur"" >> /home/masternode/scripts/Node3Load
			./VM_Scaling.sh "node3" $VMname $CPUreq $Currentcpu $Memcur
		elif [ $NODE2IDLE_MEM -ge $Memcur && $NODE2IDLE -ge $CPUreq ]; then
			echo "Migrating from Node 1 to Node 2"
			`ssh node1@192.168.1.105 virsh migrate --live $VMname qemu+ssh://node2@192.168.1.106/system`
			sed -i "/${VMname}/d" /home/masternode/scripts/Node1Load
			echo ""$VMname"	"$Currentcpu"	"$Maxcpu"	"$Memcur"" >> /home/masternode/scripts/Node2Load
			./VM_Scaling.sh "node2" $VMname $CPUreq $Currentcpu $Memcur
		else
		echo "Cannot Scale or Migrate"
		fi
	elif [[ $NODE2IDLE_MEM -gt $MemCur && $NODE2IDLE -ge $CPUreq ]]; then
		echo "Migrating from Node 1 to Node 2"
		`ssh node1@192.168.1.105 virsh migrate --live $VMname qemu+ssh://node2@192.168.1.106/system`
		sed -i "/${VMname}/d" /home/masternode/scripts/Node1Load
		echo ""$VMname"	"$Currentcpu"	"$Maxcpu"	"$Memcur"" >> /home/masternode/scripts/Node2Load
		./VM_Scaling.sh "node2" $VMname $CPUreq $Currentcpu $Memcur
	else
	echo "Cannot Scale or Migrate"
	fi
elif [ "$Nodename" = "node2" ]; then
	NODE1IDLE=$(($THRESHOLD - $NODE1CPU)) #6
	NODE3IDLE=$(($THRESHOLD - $NODE3CPU)) #4
	NODE1IDLE_MEM=$(($MEM_THRESHOLD - $NODE1MEM)) #512
	echo $NODE1IDLE_MEM
	NODE3IDLE_MEM=$(($MEM_THRESHOLD - $NODE3MEM)) #768
	echo $NODE3IDLE_MEM
	if [[ $NODE3IDLE_MEM -gt $NODE1IDLE_MEM && $NODE3IDLE_MEM -gt $MemCur ]]; then
		if [ $NODE3IDLE -ge $CPUreq ]; then
			echo "Migrating from Node 2 to Node 3"
			`ssh node2@192.168.1.106 virsh migrate --live $VMname qemu+ssh://node3@192.168.1.108/system`
			sed -i "/${VMname}/d" /home/masternode/scripts/Node2Load
			echo ""$VMname"	"$Currentcpu"	"$Maxcpu"	"$Memcur"" >> /home/masternode/scripts/Node3Load
			./VM_Scaling.sh "node3" $VMname $CPUreq $Currentcpu $Memcur
		elif [[ $NODE1IDLE_MEM -ge $Memcur && $NODE1IDLE -ge $CPUreq ]]; then
			echo "Migrating from Node 2 to Node 1"
			`ssh node2@192.168.1.106 virsh migrate --live $VMname qemu+ssh://node1@192.168.1.105/system`
			sed -i "/${VMname}/d" /home/masternode/scripts/Node2Load
			echo ""$VMname"	"$Currentcpu"	"$Maxcpu"	"$Memcur"" >> /home/masternode/scripts/Node1Load
			./VM_Scaling.sh "node1" $VMname $CPUreq $Currentcpu $Memcur
		else
		echo "Cannot Scale or Migrate"
		fi
	elif [[ $NODE1IDLE_MEM -gt $MemCur && $NODE1IDLE -ge $CPUreq ]]; then
		echo "Migrating from Node 2 to Node 1"
		`ssh node2@192.168.1.106 virsh migrate --live $VMname qemu+ssh://node1@192.168.1.105/system`
		sed -i "/${VMname}/d" /home/masternode/scripts/Node2Load
		echo ""$VMname"	"$Currentcpu"	"$Maxcpu"	"$Memcur"" >> /home/masternode/scripts/Node1Load
		./VM_Scaling.sh "node1" $VMname $CPUreq $Currentcpu $Memcur
	else
	echo "Cannot Scale or Migrate"
	fi
else
	NODE2IDLE=$(($THRESHOLD - $NODE2CPU))
	NODE1IDLE=$(($THRESHOLD - $NODE1CPU))
	NODE2IDLE_MEM=$(($MEM_THRESHOLD - $NODE2MEM))
	NODE1IDLE_MEM=$(($MEM_THRESHOLD - $NODE1MEM))

	if [[ $NODE2IDLE_MEM -gt $NODE1IDLE_MEM && $NODE2IDLE_MEM -gt $MemCur ]]; then
		if [[ $NODE2IDLE -ge $CPUreq ]]; then
			echo "Migrating from Node 3 to Node 2"
			`ssh node3@192.168.1.108 virsh migrate --live $VMname qemu+ssh://node2@192.168.1.106/system`
			sed -i "/${VMname}/d" /home/masternode/scripts/Node3Load
			echo ""$VMname"	"$Currentcpu"	"$Maxcpu"	"$Memcur"" >> /home/masternode/scripts/Node2Load
			./VM_Scaling.sh "node2" $VMname $CPUreq $Currentcpu $Memcur
		elif [[ $NODE1IDLE_MEM -ge $Memcur && $NODE1IDLE -ge $CPUreq ]]; then
			echo "Migrating from Node 3 to Node 1"
			`ssh node3@192.168.1.108 virsh migrate --live $VMname qemu+ssh://node1@192.168.1.105/system`
			sed -i "/${VMname}/d" /home/masternode/scripts/Node3Load
			echo ""$VMname"	"$Currentcpu"	"$Maxcpu"	"$Memcur"" >> /home/masternode/scripts/Node1Load
			./VM_Scaling.sh "node1" $VMname $CPUreq $Currentcpu $Memcur
		else
		echo "Cannot Scale or Migrate"
		fi
	elif [[ $NODE1IDLE_MEM -gt $MemCur && $NODE1IDLE -ge $CPUreq ]]; then
		echo "Migrating from Node 3 to Node 1"
		`ssh node3@192.168.1.108 virsh migrate --live $VMname qemu+ssh://node1@192.168.1.105/system`
		sed -i "/${VMname}/d" /home/masternode/scripts/Node3Load
		echo ""$VMname"	"$Currentcpu"	"$Maxcpu"	"$Memcur"" >> /home/masternode/scripts/Node1Load
		./VM_Scaling.sh "node1" $VMname $CPUreq $Currentcpu $Memcur
	else
	echo "Cannot Scale or Migrate"
	fi
fi
echo "Migration done"
