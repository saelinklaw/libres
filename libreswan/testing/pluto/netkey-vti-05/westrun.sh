ipsec auto --up westnet-eastnet-vti
# Without the sleep, XfrmInNoPols shows first packet sometimes goes out before policy is in place?
sleep 1
../../pluto/bin/ping-once.sh --up -I 192.1.99.1 192.1.99.254
ipsec whack --trafficstatus
ip addr show dev vti0
echo done
