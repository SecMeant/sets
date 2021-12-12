#!/usr/bin/bash
source ~/.local/share/colors.sh

RAM=32768
CPUS=24

OPTS=""
DEBUG=N
DISP=Y
BACKGROUND=N

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
		bg|background)
			BACKGROUND="Y" ;;
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

CMD="qemu-system-x86_64 ${OPTS} \
-hda defiled-drive.img \
-boot d \
-m ${RAM} \
-cpu host \
-smp cpus=${CPUS} \
--enable-kvm \
-net user,hostfwd=tcp::10022-:22,hostfwd=tcp::4242-:4242,hostfwd=tcp::1337-:1337,hostfwd=tcp::1338-:1338 \
-net nic \
"

[ "${BACKGROUND}" == "Y" ] && CMD="$CMD &"

$CMD

[ $? -eq 0 ] || echo -e "defil3d-srv ${COLOR_RED}failed${COLOR_NONE} to start."
