# Should show "ESP" and not "ESP/NAT"
ipsec whack --name road-eastnet-nonat --initiate
../../pluto/bin/ping-once.sh --up 192.0.2.254
ipsec whack --trafficstatus
echo done
