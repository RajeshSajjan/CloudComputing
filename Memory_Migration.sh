#!/bin/bash

VMname=$1 
Nodename=$2
Currentcpu=$3 
Maxcpu=$4
Memcur=$5
CPUreq=$6
CurMem=$7

echo " starting Migration"


NODE1MEM=`awk '{sum+=$4} END {print sum}' /home/masternode/scripts/Node1Load`
NODE2MEM=`awk '{sum+=$4} END {print sum}' /home/masternode/scripts/Node2Load`
NODE3MEM=`awk '{sum+=$4} END {print sum}' /home/masternode/scripts/Node3Load`

MEM_THRESHOLD=7340032 #For Migration
MAX_MEM=1048576


if [ "$Nodename" = "node1" ]; then
	NODE2IDLE_MEM=$(($MEM_THRESHOLD - $NODE2MEM))
	NODE3IDLE_MEM=$(($MEM_THRESHOLD - $NODE3MEM))
	
	if [ $NODE3IDLE_MEM -gt $NODE2IDLE_MEM && $NODE3IDLE_MEM -gt $Memcur ]; then
		
			echo "Migrating from Node 1 to Node 3"
			`ssh node1@192.168.1.105 virsh migrate --live $VMname qemu+ssh://node3@192.168.1.108/system`
			sed -i "/${VMname}/d" /home/masternode/scripts/Node1Load
			echo ""$VMname"	"$Currentcpu"	"$Maxcpu"	"$Memcur"" >> /home/masternode/scripts/Node3Load
			./VM_Scaling.sh "node3" $VMname $CPUreq $Currentcpu 
		elif [ $NODE2IDLE_MEM -ge $Memcur  ]; then
			echo "Migrating from Node 1 to Node 2"
			`ssh node1@192.168.1.105 virsh migrate --live $VMname qemu+ssh://node2@192.168.1.106/system`
			sed -i "/${VMname}/d" /home/masternode/scripts/Node1Load
			echo ""$VMname"	"$Currentcpu"	"$Maxcpu"	"$Memcur"" >> /home/masternode/scripts/Node2Load
			./VM_Scaling.sh "node2" $VMname $CPUreq $Currentcpu 
		else
		echo "Cannot Scale or Migrate"
		
	fi
elif [ "$Nodename" = "node2" ]; then
	
	NODE1IDLE_MEM=$(($MEM_THRESHOLD - $NODE1MEM))
	NODE3IDLE_MEM=$(($MEM_THRESHOLD - $NODE3MEM))

	if [ $NODE3IDLE_MEM -gt $NODE1IDLE_MEM && $NODE3IDLE_MEM -gt $MemCur ]; then
		
			echo "Migrating from Node 2 to Node 3"
			`ssh node2@192.168.1.106 virsh migrate --live $VMname qemu+ssh://node3@192.168.1.108/system`
			sed -i "/${VMname}/d" /home/masternode/scripts/Node2Load
			echo ""$VMname"	"$Currentcpu"	"$Maxcpu"	"$Memcur"" >> /home/masternode/scripts/Node3Load
			./VM_Scaling.sh "node3" $VMname $CPUreq $Currentcpu
		elif [ $NODE1IDLE_MEM -ge $Memcur  ]; then
			echo "Migrating from Node 2 to Node 1"
			`ssh node2@192.168.1.106 virsh migrate --live $VMname qemu+ssh://node1@192.168.1.105/system`
			sed -i "/${VMname}/d" /home/masternode/scripts/Node2Load
			echo ""$VMname"	"$Currentcpu"	"$Maxcpu"	"$Memcur"" >> /home/masternode/scripts/Node1Load
			./VM_Scaling.sh "node1" $VMname $CPUreq $Currentcpu 
		else
		echo "Cannot Scale or Migrate"
		
	fi
else
	
	NODE2IDLE_MEM=$(($MEM_THRESHOLD - $NODE2MEM))
	NODE1IDLE_MEM=$(($MEM_THRESHOLD - $NODE1MEM))

	if [ $NODE2IDLE_MEM -gt $NODE1IDLE_MEM && $NODE2IDLE_MEM -gt $MemCur ]; then
		
			echo "Migrating from Node 3 to Node 2"
			`ssh node3@192.168.1.108 virsh migrate --live $VMname qemu+ssh://node2@192.168.1.106/system`
			sed -i "/${VMname}/d" /home/masternode/scripts/Node3Load
			echo ""$VMname"	"$Currentcpu"	"$Maxcpu"	"$Memcur"" >> /home/masternode/scripts/Node2Load
			./VM_Scaling.sh "node2" $VMname $CPUreq $Currentcpu
		elif [ $NODE1IDLE_MEM -ge $Memcur ]; then
			echo "Migrating from Node 3 to Node 1"
			`ssh node3@192.168.1.108 virsh migrate --live $VMname qemu+ssh://node1@192.168.1.105/system`
			sed -i "/${VMname}/d" /home/masternode/scripts/Node3Load
			echo ""$VMname"	"$Currentcpu"	"$Maxcpu"	"$Memcur"" >> /home/masternode/scripts/Node1Load
			./VM_Scaling.sh "node1" $VMname $CPUreq $Currentcpu 
		else
		echo "Cannot Scale or Migrate"
		
	fi
fi
echo "Migration done"

