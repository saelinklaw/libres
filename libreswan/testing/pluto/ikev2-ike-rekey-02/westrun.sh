ipsec auto --up west
../../pluto/bin/ping-once.sh --up -I 192.0.1.254 192.0.2.254
ipsec whack --trafficstatus
echo "sleep 50"
sleep 50
../../pluto/bin/ping-once.sh --up -I 192.0.1.254 192.0.2.254
ipsec whack --trafficstatus
ipsec status |grep STATE_
echo "sleep 50"
sleep 50
../../pluto/bin/ping-once.sh --up -I 192.0.1.254 192.0.2.254
echo done
