#!/bin/bash
# Backup home

proper_ans="Yes, Im sure"
echo -n "Are you sure? Type '${proper_ans}': "
read ans

if [ "$ans" != "$proper_ans" ]; then
	echo "Ok, leaving.";
	exit 1;
fi

bpname="bph$(cat /etc/hostname)$(date +%d%m%Y)${$}.tar.gz"
tmpbpname="/tmp/${bpname}"
color_default="\033[0m"
color_done="\033[0;32m"
username=$(whoami)
taropt=""

echo "Output file name: ${bpname}"

echo -n "Calculating size of data to compress . . . "
total_size=$(du --exclude-from=/home/${username}/.bpexclude -sb /home/${username} | cut -f 1)
checkpoint=$(echo ${total_size}/50000 | bc)
echo -e "${color_done}DONE${color_default}"

command -v numfmt
if [ "$?" != "0" ]; then
	echo "SIZE: ${total_size}B"
else
	echo "SIZE: $(numfmt --to=iec-i --suffix=B ${total_size})"
fi

echo "Copying and compressing. . . "

# This probraby has to be the first appendted option
# tar needs this at the very beggining
if [ -f /home/${username}/.bpexclude ]; then
	taropt="${taropt} --exclude-from=/home/${username}/.bpexclude"
fi

echo -n "Progress: ["
for i in $(seq 1 50)
do
	echo -n " "
done
echo -n "]"
for i in $(seq 1 51)
do
	echo -ne "\x08"
done

tar $taropt -cp --record-size=1K --checkpoint="${checkpoint}" --checkpoint-action="ttyout=#" -f - /home/${username} 2>/dev/null | gzip > "${tmpbpname}"
errc=$?
if [ "${errc}" != "0" ]; then
	echo "Error: tar exited with code ${errc}";
	exit $?;
fi

echo -e "${color_done}DONE${color_default}"

echo -n "Moving backup file to current directory . . . "
mv ${tmpbpname} ${bpname}

errc=$?
if [ "${errc}" != "0" ]; then
	echo "Error: mv exited with code ${errc}";
	exit $?;
fi

echo -e "${color_done}DONE${color_default}"

echo -e "${color_done}OK${color_default}"
exit 0
