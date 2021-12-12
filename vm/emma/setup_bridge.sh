#!/bin/sh
/usr/bin/ip link add br0 type bridge && \
/usr/bin/ip link set enp4s0 master br0 && \
/usr/bin/dhclient br0
