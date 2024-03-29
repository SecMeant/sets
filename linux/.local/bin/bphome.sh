#!/bin/bash
# Backup home

# $1 == directory which is backed-up, home dir if empty
# $2 == backup output directory, /tmp by default and when done moved to pwd

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
bpexclude=`mktemp`
bprepos="/tmp/bphome_repos"
repofinder="getrepos.sh"
color_default="\033[0m"
color_done="\033[0;32m"
color_warn="\033[33m"
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

rm -f ${bpexclude}
cp ${bpexclude_user} ${bpexclude} 2>/dev/null

echo -n "Searching for mountpoits to exclude . . . "

bptarget_escaped=$(echo ${bptarget} | sed 's/\//\\\//g;s/ /\\ /g')
cut -f 2 -d " " /proc/mounts | sed "/${bptarget_escaped}/ !d; /^${bptarget_escaped}\/*$/ d; s/$/\/\*/" >> ${bpexclude}

echo -e "${color_done}DONE${color_default}"

echo -n "Searching for git repositories to exclude . . . "

# Export default excludes
echo -e '/dev/*' >> "${bpexclude}"
echo -e '/sys/*' >> "${bpexclude}"
echo -e '/proc/*' >> "${bpexclude}"
echo -e '/run/*' >> "${bpexclude}"

if command -v "${repofinder}"; then
	"${repofinder}" > "${bprepos}"
	sed "s/\t.*$//;s/$/\/\*/;" "${bprepos}" >> "${bpexclude}"
	echo -e "${color_done}DONE${color_default}"
	echo -e "Found repos:"
	sed "s/^/\t/" ${bprepos}
	rm ${bprepos}
else
	echo -e "${color_warn}WARNING: getrepos.sh not found. Unable to search for repositories.${color_default}"
fi

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
	echo -e "\nError: tar exited with code ${errc}";
	exit $?;
fi

echo -e "] ${color_done}DONE${color_default}"

if [ `stat -c %i "${tmpbpname}"` -ne `stat -c %i "${bpname}"` ]; then
	echo -n "Moving backup file to current directory . . . "
	mv ${tmpbpname} ${bpname}
fi

errc=$?
if [ "${errc}" != "0" ]; then
	echo "Error: mv exited with code ${errc}";
	exit $?;
fi

echo -e "${color_done}DONE${color_default}"

echo -e "${color_done}OK${color_default}"
exit 0
