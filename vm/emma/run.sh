#!/usr/bin/bash
source ~/.local/share/colors.sh

VM_NAME="emma-srv"

RAM=32768
CPUS=24

OPTS=""
DEBUG=N
DISP=Y
BIOS=N

UEFI_ROM_PATH="/usr/share/ovmf/x64/OVMF.fd"

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
		bios)
			BIOS=Y ;;
		uefi)
			BIOS=N ;;
	esac

	shift
done

[ "${BIOS}" == "N" ] && [ ! -f "${UEFI_ROM_PATH}" ] \
	&& echo "${COLOR_RED}Couldn't find UEFI ROM at ${UEFI_ROM_PATH}. Switching to BIOS.${COLOR_RED}" \
	&& BIOS=Y

echo -e "Starting ${VM_NAME}...\n"

echo "Config:"
[ "${DEBUG}" == "Y" ] \
	&& echo -e "debug\t${COLOR_GREEN}ON${COLOR_NONE}" && OPTS="${OPTS} -s -S " \
	|| echo -e "debug\t${COLOR_RED}OFF${COLOR_NONE}"

[ "${DISP}" == "N" ] \
	&& echo -e "display\t${COLOR_RED}OFF${COLOR_NONE}" && OPTS="${OPTS} -nographic" \
	|| echo -e "display\t${COLOR_GREEN}ON${COLOR_NONE}"

[ "${BIOS}" == "Y" ] \
	&& echo -e "UEFI\t${COLOR_RED}OFF${COLOR_NONE}" \
	|| { echo -e "UEFI\t${COLOR_GREEN}ON${COLOR_NONE}" && OPTS="${OPTS} -bios ${UEFI_ROM_PATH}"; }

echo -e "\n"


qemu-system-x86_64 ${OPTS} \
-hda emma-drive.img \
-cdrom "./archlinux-2021.03.01-x86_64.iso" \
-boot c \
-m ${RAM} \
-cpu host \
-smp cpus=${CPUS} \
--enable-kvm \
-net user,hostfwd=tcp::30022-:22 \
-net nic

#-device virtio-net-pci,netdev=n1 \
#-netdev tap,id=n1,br=br0,"helper=/usr/lib/qemu/qemu-bridge-helper"

[ $? -eq 0 ] || echo -e "${VM_NAME} ${COLOR_RED}failed${COLOR_NONE} to start."
