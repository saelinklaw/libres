ipsec auto --up westnet-eastnet-vti
# since we have vti-routing=no, no marking, so unencrypted packets are dropped
../../pluto/bin/ping-once.sh --down -I 192.0.1.254 192.0.2.254
ipsec whack --trafficstatus
ip route add 192.0.2.0/24 dev vti0
# now packets into vti0 device will get marked, and encrypted and counted
../../pluto/bin/ping-once.sh --up -I 192.0.1.254 192.0.2.254
ipsec whack --trafficstatus
# ensure no error on delete
ipsec auto --delete westnet-eastnet-vti
echo done
