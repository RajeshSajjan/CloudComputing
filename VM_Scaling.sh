#!/bin/bash
NODE=$1
VMname=$2
CPUreq=$3
OLDCPU=$4
UNIT="K"
NEWMEMREQ=$5${UNIT}

echo "started scaling"
#echo $NODE
#echo $CPUreq
#echo $VMname
#echo $OLDCPU
echo $NEWMEMREQ

if [ "$NODE" = "node1" ]; then
	echo "Upscaling "$VMname" on node1"
	`ssh node1@192.168.1.105 virsh setvcpus $VMname $CPUreq --live`
	`ssh node1@192.168.1.105 virsh setmem $VMname $NEWMEMREQ --live`
	 sed -i "s/${VMname}	${OLDCPU}/${VMname}	${CPUreq}/" /home/masternode/scripts/Node1Load
elif [ "$NODE" = "node2" ]; then
	echo "Upscaling "$VMname" on node2"
	`ssh node2@192.168.1.106 virsh setvcpus $VMname $CPUreq --live`
	`ssh node2@192.168.1.106 virsh setmem $VMname $NEWMEMREQ --live`
	 sed -i "s/${VMname}	${OLDCPU}/${VMname}	${CPUreq}/" /home/masternode/scripts/Node2Load
else	
	echo "Upscaling "$VMname" on node3"
	`ssh node3@192.168.1.108 virsh setvcpus $VMname $CPUreq --live`
	`ssh node3@192.168.1.108 virsh setmem $VMname $NEWMEMREQ --live`
	 sed -i "s/${VMname}	${OLDCPU}/${VMname}	${CPUreq}/" /home/masternode/scripts/Node3Load
fi

echo "Scaling done"

