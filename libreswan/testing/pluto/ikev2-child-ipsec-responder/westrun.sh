# this connections auto=start on east
# ipsec auto --up westnet-eastnet-ikev2a
# give time to establish the first connection
sleep 15
../../pluto/bin/ping-once.sh --up -I 192.0.1.254 192.0.2.254
ipsec auto --up westnet-eastnet-ikev2b
../../pluto/bin/ping-once.sh --up -I 192.0.100.254 192.0.200.254
ipsec whack --trafficstatus
echo done
