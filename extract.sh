#!/bin/bash
i=1
P="Workload"
U="_"
#if [ $i -eq 1 ]
#then
#	line=`sed -n 1p Alloc`
#	IFS=, read -r f2 f3 f4 f5 f6 f7<<<"$line"
#	VMname=${f3}${U}${f4}${U}${f5}${U}${P}
#	sed -n 1,14p Alloc > $VMname
#fi
for j in `seq 0 9`
do
	start=$((14*$(($j))+1))
	end=$((13+$start))
	line=`sed -n "$start"p New_Alloc`
	IFS=, read -r f2 f3 f4 f5 f6 f7<<<"$line"
	VMname=${f3}${U}${f4}${U}${f5}
	VM_workload_file=${VMname}${U}${P}
	sed -n "$start,$end"p New_Alloc > /home/masternode/project/workload/$VM_workload_file
	echo $VMname

	./VM_submitjob.sh $VMname ${f6} ${f7} 
	sleep 150 #& echo "Finished submit job"
done

