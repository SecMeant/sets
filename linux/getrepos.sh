#!/bin/sh

if [ ! -f ~/.bprepos ]; then
	exit 0
fi

while read repopath;
do
	for f in $(find /home/holz/etc/github/ -maxdepth 1 -type d)
	do
		pushd $f > /dev/null
		url=$(git config --get remote.origin.url)
		if [ ! -z "${url}" ]; then
			echo -e "$f\t${url}"
		fi
		popd > /dev/null
	done
done < ~/.bprepos
