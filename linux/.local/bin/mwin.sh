#!/bin/bash
arg="$1"
case $arg in
	left)
		WIDTH=500
		HEIGHT=300
		;;
	right)
		WIDTH=2400
		HEIGHT=300
		;;
	*)
		exit 0
		;;
esac

xdotool windowmove $(cwin) $WIDTH $HEIGHT
