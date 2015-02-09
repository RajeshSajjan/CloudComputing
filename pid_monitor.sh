#!/bin/bash

nTimes=10; 
delay=0.5;

while true
do
	nPid=`ps -ef|grep "stress"|grep -v "grep"|awk '{print $2}'`;
	simulationPID=`echo $nPid | awk '{print $1}'`
	if [ ! -z "$simulationPID" ]
	then
		strCalcCpu=`top -d $delay -b -n $nTimes -p $simulationPID \
	  	|grep $simulationPID \
  		|sed -r -e "s;\s\s*; ;g" -e "s;^ *;;" \
	  	|cut -d' ' -f9 \
 		|tr '\n' '+' \
	 	|sed -r -e "s;(.*)[+]$;\1;" -e "s/.*/scale=2;(&)\/$nTimes/"`;
		nPercCpu=`echo "$strCalcCpu" |bc -l`


		strCalcMem=`top -d $delay -b -n $nTimes -p $simulationPID \
	        |grep $simulationPID \
        	|sed -r -e "s;\s\s*; ;g" -e "s;^ *;;" \
	        |cut -d' ' -f10 \
 		|tr '\n' '+' \
        	|sed -r -e "s;(.*)[+]$;\1;" -e "s/.*/scale=2;(&)\/$nTimes/"`;
        	nPercMem=`echo "$strCalcMem" |bc -l`
		if [ "$nPercCpu" = "" ]; then
			nPercCpu=0
		fi
		if [ "$nPercMem" = "" ]; then
			nPercMem=0
		fi
		echo "$1,$nPercCpu,$nPercMem" >> /root/monitor_logs/VM_monitor.log
		tail -n1 /root/monitor_logs/VM_monitor.log | sshpass -pmasternode1 ssh -o StrictHostKeyChecking=no masternode@192.168.1.109 'cat >> /home/masternode/scripts/VM_monitor.log'
		tail -n1 /root/monitor_logs/VM_monitor.log | sshpass -pmasternode1 ssh -o StrictHostKeyChecking=no masternode@192.168.1.109 'cat >> /home/masternode/scripts/$1.log'
		sleep 1
	else
		break
	fi
done
