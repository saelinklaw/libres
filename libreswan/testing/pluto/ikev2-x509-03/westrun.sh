ipsec auto --up ikev2-westnet-eastnet-x509-cr
../../pluto/bin/ping-once.sh --down -I 192.0.1.254 192.0.2.254
ipsec whack --trafficstatus
echo "done"
