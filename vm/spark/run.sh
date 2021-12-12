#!/usr/bin/bash
source ~/.local/share/colors.sh

RAM=8192
CPUS=24

OPTS=""
DEBUG=N
DISP=Y

while [[ $# -gt 0 ]]
do
	key="$1"

	case $key in
		debug)
			DEBUG="Y" ;;
		display)
			DISP="Y" ;;
		nodisplay|nodisp)
			DISP="N" ;;
	esac

	shift
done

echo -e "Starting defil3d-srv ...\n"

echo "Config:"
[ "${DEBUG}" == "Y" ] \
	&& echo -e "debug\t${COLOR_GREEN}ON${COLOR_NONE}" && OPTS="${OPTS} -s -S " \
	|| echo -e "debug\t${COLOR_RED}OFF${COLOR_NONE}"

[ "${DISP}" == "N" ] \
	&& echo -e "display\t${COLOR_RED}OFF${COLOR_NONE}" && OPTS="${OPTS} -nographic" \
	|| echo -e "display\t${COLOR_GREEN}ON${COLOR_NONE}" \

echo -e "\n"

qemu-system-x86_64 ${OPTS} \
-hda spark_new.img \
-cdrom Win10_20H2_English_x64.iso \
-boot c \
-m ${RAM} \
-cpu host \
-smp cpus=${CPUS} \
--enable-kvm \
#-device e1000,netdev=n1 \
#-netdev tap,id=n1,br=br0,"helper=/usr/lib/qemu/qemu-bridge-helper"

#-net user,hostfwd=tcp::10022-:22,hostfwd=tcp::4242-:4242,hostfwd=tcp::1337-:1337,hostfwd=tcp::1338-:1338 \
#-net user,hostfwd=tcp::14147-:14147 \
-net user \
-net nic \

[ $? -eq 0 ] || echo -e "defil3d-srv ${COLOR_RED}failed${COLOR_NONE} to start."
