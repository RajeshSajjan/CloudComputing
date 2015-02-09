#!/bin/bash
n=$1
m=$2
	sleep 2
	for i in `seq 0 $(($m-1))`
	do
	for j in `seq 0 $(($n-1))`
		do
			x[$(($n*$i+$j))]=100
	done
	done

	#echo "hereeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee"

	sleep 5

	for i in `seq 0 $(($m-1))`
	do
	sleep 0.01
	for j in `seq 0 $(($n-1))`
	do
		matrix2[$(($n*$i+$j))]=x[$(($n*$i+$j))]
	done
	done

	sleep 5
	#echo "ttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttll"	

	for i in `seq 0 $(($m-1))`
	do
	for j in `seq 0 $(($n-1))`
	do
		matrix3[$(($n*$i+$j))]=x[$(($n*$i+$j))]+matrix2[$(($n*$j+$i))]
	done
	done
	#echo "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
sleep 0.1
MAT=("${matrix3[@]}")
unset MAT
	for i in `seq 0 2`
	do
		for j in `seq 0 $(($n-1))`
		do
		echo -ne "${x[$(($n*$i+$j))]}\t" >> sample.txt
		done
		MatrixArray=( `cat "sample.txt" `)
	done

#echo " Calling Termination"

#./VM_Terminate.sh 

echo " Job completed "
