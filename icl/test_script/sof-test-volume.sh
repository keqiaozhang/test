#!/bin/bash

MAXLOOP=10000

rand(){
	min=$1
	max=$(($2-$min+1))
	num=$(date +%s%N)
	echo $(($num%$max+$min))
}

err_check(){
	ERROR=$(dmesg | grep sof-audio | grep -E "error|failed|timed out|panic|oops")
	if [ ! -z "$ERROR" ]; then
		dmesg > boot_fail.log
		exit 1
	fi
}
		 
int=0
while [ $int -lt $MAXLOOP ]
do
	echo "test $int"
	PGA_ID=$(rand 1 7)
	echo "Volume kctl ID: $PGA_ID"
	if [ $PGA_ID == 2 ] || [ $PGA_ID == 3 ]; then
		for volume in $(seq 0 32)
		do
			amixer -c0 cset name='PGA'$PGA_ID'.0 Master Capture Volume '$PGA_ID'' $volume
		done
	else
		for volume in $(seq 0 32)
		do
			amixer -c0 cset name='PGA'$PGA_ID'.0 Master Playback Volume '$PGA_ID'' $volume
		done
	fi
	sleep 0.1
	err_check
	let int++
done
