#!/bin/sh
if [ "${CONFIG}x" == "x" ]; then
	CONFIG=/data/config.ini
fi

if [ ! -e $CONFIG ]; then
	cp /config.ini /data
fi

brctl addbr virbr0
ip link set dev virbr0 up
if [ "${BRIDGE_ADDRESS}x" == "x" ]; then
  BRIDGE_ADDRESS=172.84.9.1/24
fi

if [ "${DHCP_START}x" == "x" ]; then
  DHCP_START=172.84.9.10
fi

if [ "${DHCP_END}x" == "x" ]; then
  DHCP_END=172.84.9.100
fi

if [ "${BRIDGE_INTERFACE}x" == "x" ]; then
  BRIDGE_INTERFACE=eth0
fi

ip ad add ${BRIDGE_ADDRESS} dev virbr0
iptables -t nat -A POSTROUTING -o ${BRIDGE_INTERFACE} -j MASQUERADE

dnsmasq -i virbr0 -z -h --dhcp-range=${DHCP_START},${DHCP_END},4h
dockerd --storage-driver=vfs --data-root=/data/docker/ &
gns3server -A --config /data/config.ini
