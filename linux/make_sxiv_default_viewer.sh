#!/bin/sh

command -v sxiv || "Error: Could not find sxiv."
command -v xdg-mime || "Error: Could not find xdg-mime."

mime_types='''
image/bmp
image/gif
image/jpeg
image/jpg
image/png
image/tiff
image/x-bmp
image/x-portable-anymap
image/x-portable-bitmap
image/x-portable-graymap
image/x-tga
image/x-xpixmap
'''

for mime in $mime_types; do
	xdg-mime default sxiv.desktop $mime
done