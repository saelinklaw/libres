ipsec auto --up road-eastnet-ikev2
../../pluto/bin/ping-once.sh --up 192.0.2.254
ipsec whack --trafficstatus
echo done
