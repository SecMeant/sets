#!/bin/bash
# Backup home

proper_ans="Yes, Im sure"
echo -n "Are you sure? Type '${proper_ans}': "
read ans

if [ "$ans" != "$proper_ans" ]; then
	echo "Ok, leaving.";
	exit 1;
fi

username=$(whoami)
bpname="bph$(cat /etc/hostname)$(date +%d%m%Y)${$}.tar.gz"
tmpbpname="/tmp/${bpname}"
bpexclude_user="/home/${username}/.bpexclude"
bpexclude="/tmp/bpexclude"
color_default="\033[0m"
color_done="\033[0;32m"
taropt=""

if [ "$1" != "" ]; then
	bptarget="$1"
else
	bptarget="/home/${username}"
fi

if [ "$2" != "" ]; then
	tmpbpname="$2/${bpname}"
	bpname="$2/${bpname}"
fi

distro=$(cat /etc/issue | cut -f 1 -d " ")

if [ "${distro}" == "Arch" ]; then
	echo "Current distro is Arch - dumping installed packages."
	comm -23 <(pacman -Qeq | sort) <(pacman -Qgq base-devel | sort) > ~/.packages
fi

echo -n "Searching for mountpoits to exclude . . . "

trap "rm -f ${bpexclude} ${tmpbpname}"
truncate ${bpexclude} --size 0
cp ${bpexclude_user} ${bpexclude} 2>/dev/null
bptarget_escaped=$(echo ${bptarget} | sed 's/\//\\\//g;s/ /\\ /g')
cut -f 2 -d " " /proc/mounts | sed "s/$/\/\*/; /${bptarget_escaped}\/.*/ !d" >> ${bpexclude}

echo -e "${color_done}DONE${color_default}"
echo -e "Excluded dirs:"
sed "s/^/\t/" "${bpexclude}"


echo -e "\nOutput file name: ${bpname}"

echo -n "Calculating size of data to compress . . . "

if [ -f ${bpexclude} ]; then
	total_size=$(du --exclude-from=${bpexclude} -sb ${bptarget} | cut -f 1)
else
	total_size=$(du -sb ${bptarget} | cut -f 1)
fi

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
if [ -f ${bpexclude} ]; then
	taropt="${taropt} --exclude-from=${bpexclude}"
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

tar $taropt -cp --record-size=1K --checkpoint="${checkpoint}" --checkpoint-action="ttyout=#" -f - ${bptarget} 2>/dev/null | gzip > "${tmpbpname}"
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
