#!/bin/sh

bridge=br0
netif=

while :; do
	case $1 in
		-b|--bridge)
			if [ -n "$2" ]; then
				bridge=$2
				shift
			else
				printf 'ERROR: "-b / --bridge" requires a bridge name argument.\n' >&2
				exit 1
			fi
			;;
		-n|--netif)
			if [ -n "$2" ]; then
				netif=$2
				shift
			else
				printf 'ERROR: "-n / --netif" requires a network interface name argument.\n' >&2
				exit 1
			fi
			;;
		-?*)
			printf 'WARN: Unknown option (ignored): %s\n' "$1" >&2
			;;
		*)
			break
	esac

	shift
done

echo -n 'Looking up dhclient ... '
prog_dhclient=$(command -v dhclient)
if [ -z "$prog_dhclient" ]; then
	echo 'NOT FOUND'
	exit 1
else
	echo 'OK'
fi

echo -n 'Looking up ip ... '
prog_ip=$(command -v ip)
if [ -z "$prog_ip" ]; then
	echo 'NOT FOUND'
	exit 2
else
	echo 'OK'
fi

printf 'Running for: bridge=%s netif=%s\n' "$bridge" "$netif" >&2

if [ -z "$netif" ]; then
	printf 'ERROR: "-n / --netif" option is required.\n' >&2
	exit 1
fi

"$prog_ip" link add $bridge type bridge
"$prog_ip" link set $netif master $bridge
"$prog_dhclient" $bridge

