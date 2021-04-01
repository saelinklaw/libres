# one packet, which gets eaten by XFRM, so east does not initiate
../../pluto/bin/ping-once.sh --down -I 192.1.3.209 192.1.2.23
# wait on OE to establish
sleep 2
# should show established tunnel and no bare shunts
ipsec whack --trafficstatus
# ping should succeed through tunnel
../../pluto/bin/ping-once.sh --up -I 192.1.3.209 192.1.2.23
ipsec whack --trafficstatus
echo done
