#!/bin/bash

# ************************************************** #
# True Low Power scirpt                              #
# Sets max cpu clock freq to value given as argument #
# ************************************************** #

if [[ $EUID -ne 0 ]]; then
	echo "This script must be run as root"
	exit 1
fi

if [[ -z "$1" ]]; then
	echo "Usage: tlp.sh <new max cpu freq in MHz>"
	exit 2
fi

re='^[0-9]+$'
if ! [[ $1 =~ $re  ]]; then
	echo "Error: expected numeric argument!"
	exit 3
fi

echo "Ok -- changing to 800MHz"
echo "Caution: value migth be rounded to nearest freq supported by cpu"

for i in `seq 0 $(($(grep -c ^processor /proc/cpuinfo)-1))`;
do
	cpufreq-set -u $1MHz -c $i
done
