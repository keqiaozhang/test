#!/bin/bash

ITERATIONS=1000	# number of iterations
COUNTER=0
SUSPEND_T=5	# seconds to suspend
RESUME_T=5	# seconds to resume

random() {
  hexdump -n 2 -e '/2 "%u"' /dev/urandom
}

while [ $COUNTER -lt $ITERATIONS ]; do
	echo "Test $COUNTER"
	dmesg -C
	SUSPEND_TIME=$(( ( $(random) % suspend_interval ) +  ))
	echo “System will suspend after $SUSPEND_TIME seconds ...”
	sleep $SUSPEND_TIME
	WAKE_TIME=$(($RANDOM%5+5))
	echo "system will resume after $WAKE_TIME seconds ..."
	rtcwake -m mem -s $WAKE_TIME
	unset ERROR
	ERROR=$(dmesg | grep sof-audio | grep -E "failed | error")
	if [ ! -z "$ERROR" ]
	then
		dmesg > test_${COUNTER}_fail.log
		echo "Suspend/resume failed, see test_${COUNTER}_fail.log for details"
		exit 1
	else
		echo "Test $COUNTER success"
	fi

	dmesg > test_${COUNTER}_pass.log
	let COUNTER+=1
done
