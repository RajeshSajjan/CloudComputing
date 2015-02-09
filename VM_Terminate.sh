#!/bin/bash
sleep 3
pid=`ps -ef|grep "stress"|grep -v "grep"|awk '{print $2}'`
echo "PID"
echo $pid

while true
do
pid=`ps -ef|grep "stress"|grep -v "grep"|awk '{print $2}'`
if [ ! -z "$pid" ]
then
	echo $pid
	sleep 5
else
	echo "Shutting down"
	break
fi
done

shutdown -h now

