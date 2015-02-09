#!/bin/bash

#Getting the newly requested VM specs
echo "vm cpu number = $1"
echo "vm mem number = $2"
echo "vm cpu max number = $3"

VMCPU=`./division $1 64`
VMMEM=`./division $2 8192`

echo "vm cpu = $VMCPU"
echo "vm mem = $VMMEM"

VMVOLUME=`./volume $VMCPU $VMMEM 1`
echo "VM volume = $VMVOLUME"

#TODO: Get lock on the file

#Getting node1 specs
N1CPU=`awk '{sum+=$2} END {print sum}' Node1Load`
N1MAXCPU=`awk '{sum+=$3} END {print sum}' Node1Load`
N1MEMORY=`awk '{sum+=$4} END {print sum}' Node1Load`
Node1VMCOUNT=`awk '{sum+=1} END {print sum}' Node1Load`

if [ -n "$Node1VMCOUNT" ]; 
then
	echo ""
else
	N1MEMORY=0	
	Node1VMCOUNT=0
	N1CPU=0
	N1MAXCPU=0
fi

Node1VMCOUNT=$((${Node1VMCOUNT} + 1))

echo "NODE1Cpu = $N1CPU"
echo "NODE1mAXCpu = $N1MAXCPU"
echo "NODE1Memory = $N1MEMORY"
echo "Count = $Node1VMCOUNT"

#CPU=`grep -m 1 Total Node1Load | awk {'print $2'}`
#MAXCPU=`grep -m 1 Total Node1Load | awk {'print $3'}`
#MEMORY=`grep -m 1 Total Node1Load | awk {'print $4'}`

NODE1CPU=`./division $N1CPU 10`
NODE1MAXCPU=`./division $N1MAXCPU 10`
NODE1MEMORY=`./division $N1MEMORY 8192`

echo "NODE1Cpu = $NODE1CPU"
echo "NODE1mAXCpu = $NODE1MAXCPU"
echo "NODE1Memory = $NODE1MEMORY"

NODE1VOLUME=`./volume $NODE1CPU $NODE1MEMORY -1`
echo "Node 1 volume = $NODE1VOLUME"

#Getting node2 specs
N2CPU=`awk '{sum+=$2} END {print sum}' Node2Load`
N2MAXCPU=`awk '{sum+=$3} END {print sum}' Node2Load`
N2MEMORY=`awk '{sum+=$4} END {print sum}' Node2Load`
Node2VMCOUNT=`awk '{sum+=1} END {print sum}' Node2Load`

if [ -n "$Node2VMCOUNT" ]; 
then
	echo ""	
else
	Node2VMCOUNT=0
	N2CPU=0
	N2MAXCPU=0
	N2MEMORY=0
fi

Node2VMCOUNT=$((${Node2VMCOUNT} + 1))

#CPU=`grep -m 1 Total Node2Load | awk {'print $2'}`
#MAXCPU=`grep -m 1 Total Node2Load | awk {'print $3'}`
#MEMORY=`grep -m 1 Total Node2Load | awk {'print $4'}`

NODE2CPU=`./division $N2CPU 10`
NODE2MAXCPU=`./division $N2MAXCPU 10`
NODE2MEMORY=`./division $N2MEMORY 8192`

echo "NODE2Cpu = $NODE2CPU"
echo "NODE2mAXCpu = $NODE2MAXCPU"
echo "NODE2Memory = $NODE2MEMORY"

NODE2VOLUME=`./volume $NODE2CPU $NODE2MEMORY -1`
echo "Node 2 volume = $NODE2VOLUME"

#Getting node3 specs
N3CPU=`awk '{sum+=$2} END {print sum}' Node3Load`
N3MAXCPU=`awk '{sum+=$3} END {print sum}' Node3Load`
N3MEMORY=`awk '{sum+=$4} END {print sum}' Node3Load`
Node3VMCOUNT=`awk '{sum+=1} END {print sum}' Node3Load`

if [ -n "$Node3VMCOUNT" ]; 
then
	echo ""
else
	Node3VMCOUNT=0
	N3CPU=0
	N3MAXCPU=0
	N3MEMORY=0
fi 

Node3VMCOUNT=$((${Node3VMCOUNT} + 1))

#CPU=`grep -m 1 Total Node3Load | awk {'print $2'}`
#MAXCPU=`grep -m 1 Total Node3Load | awk {'print $3'}`
#MEMORY=`grep -m 1 Total Node3Load | awk {'print $4'}`

NODE3CPU=`./division $N3CPU 40`
NODE3MAXCPU=`./division $N3MAXCPU 40`
NODE3MEMORY=`./division $N3MEMORY 8192`

echo "NODE3Cpu = $NODE3CPU"
echo "NODE3MaxCpu = $NODE3MAXCPU"
echo "NODE3Memory = $NODE3MEMORY"

NODE3VOLUME=`./volume $NODE3CPU $NODE3MEMORY -1`
echo "Node 3 volume = $NODE3VOLUME"


#Getting master node specs
MACPU=`awk '{sum+=$2} END {print sum}' MasterLoad`
MAMAXCPU=`awk '{sum+=$3} END {print sum}' MasterLoad`
MAMEMORY=`awk '{sum+=$4} END {print sum}' MasterLoad`
MasterVMCOUNT=`awk '{sum+=1} END {print sum}' MasterLoad`

if [ -n "$MasterVMCOUNT" ]; 
then
	echo ""
else
	MasterVMCOUNT=0
	MACPU=0
	MAMAXCPU=0
	MAMEMORY=0
fi

MasterVMCOUNT=$((${MasterVMCOUNT} + 1))

#CPU=`grep -m 1 Total MasterLoad | awk {'print $2'}`
#MAXCPU=`grep -m 1 Total MasterLoad | awk {'print $3'}`
#MEMORY=`grep -m 1 Total MasterLoad | awk {'print $4'}`

MASTERCPU=`./division $MACPU 64`
MASTERMAXCPU=`./division $MAMAXCPU 64`
MASTERMEMORY=`./division $MAMEMORY 8192`

echo "MasterCpu = $MASTERCPU"
echo "MastermAXCpu = $MASTERMAXCPU"
echo "MasterMemory = $MASTERMEMORY"

MASTERVOLUME=`./volume $MASTERCPU $MASTERMEMORY -1`
echo "Master node volume = $MASTERVOLUME"

#Finding the right match for the VM
#DESTNODE=`./sortvolume $MASTERVOLUME $NODE1VOLUME $NODE2VOLUME $NODE3VOLUME $VMVOLUME $MACPU $MAMEMORY $N1CPU $N1MEMORY $N2CPU $N2MEMORY $N3CPU $N3MEMORY $1 $2`

DESTNODE=`./sortvolume $NODE1VOLUME $NODE2VOLUME $NODE3VOLUME $VMVOLUME $N1CPU $N1MEMORY $N2CPU $N2MEMORY $N3CPU $N3MEMORY $1 $2`


echo "destination node is $DESTNODE"

if [ $DESTNODE = "NULL" ]; then
	echo "No node has the capacity to add the new VM!!!!!"
else

	#need to update the node load data file
	FILENAME=$DESTNODE"Load"

	if [ $DESTNODE = "Master" ]; then
		VMNAME="Vm"$MasterVMCOUNT
	elif [ $DESTNODE = "Node1" ]; then
		VMNAME="Vm"$Node1VMCOUNT
	elif [ $DESTNODE = "Node2" ]; then
		VMNAME="Vm"$Node2VMCOUNT
	elif [ $DESTNODE = "Node3" ]; then
		VMNAME="Vm"$Node3VMCOUNT
	fi

	#echo "Vm name = $VMNAME"
	#echo "$VMNAME	$1		$3	$2" >> $FILENAME


	#place and clone the vm on the node
	ONEMB=1024
	BASE_MEM=262144
	MEM_IN_KIB=$(($ONEMB * $2))
	MEM_VM=$(($BASE_MEM + $MEM_IN_KIB))
	MEM_VM_MB=`./division $MEM_VM 1024`
	echo "$4	$1	$3	$MEM_VM_MB" >> $FILENAME
	touch placementop
	W='_Workload'
	if [ $DESTNODE = "Master" ]; then
		bash /home/masternode/scripts/cloneVM.sh $4 $DESTNODE $1 $3 $MEM_VM
	elif [ $DESTNODE = "Node1" ]; then
		#sshpass -pnode1 ssh -o StrictHostKeyChecking=no node1@192.168.1.105 bash /home/node1/project/scripts/cloneVM.sh $4 $DESTNODE $1 $3 $MEM_VM & exit 0
		#echo $4$W
		scp /home/masternode/project/workload/$4$W node1@192.168.1.105:/home/node1/project/workload/
		sshpass -pnode1 ssh -o StrictHostKeyChecking=no node1@192.168.1.105 bash /home/node1/project/scripts/cloneVM.sh $4 $DESTNODE $1 $3 $MEM_VM >> placementop & #exit 0
	elif [ $DESTNODE = "Node2" ]; then
		#sshpass -pnode2 ssh -o StrictHostKeyChecking=no node2@192.168.1.106 bash /home/node2/project/scripts/cloneVM.sh $4 $DESTNODE $1 $3 $MEM_VM & exit 0
		sshpass -pnode2 ssh -o StrictHostKeyChecking=no node2@192.168.1.106 bash /home/node2/project/scripts/cloneVM.sh $4 $DESTNODE $1 $3 $MEM_VM >> placementop & #exit 0
	elif [ $DESTNODE = "Node3" ]; then
		echo "Placing the VM on node 3"
		#sshpass -pnode3 ssh -o StrictHostKeyChecking=no node3@192.168.1.108 bash /home/node3/project/scripts/cloneVM.sh $4 $DESTNODE $1 $3 $MEM_VM & exit 0
		sshpass -pnode3 ssh -o StrictHostKeyChecking=no node3@192.168.1.108 bash /home/node3/project/scripts/cloneVM.sh $4 $DESTNODE $1 $3 $MEM_VM >> placementop & #exit 0
	fi
fi
	


