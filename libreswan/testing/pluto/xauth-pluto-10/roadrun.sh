ipsec whack --xauthpass 'use1pass' --name xauth-road-eastnet --initiate
ipsec whack --trafficstatus
../../pluto/bin/ping-once.sh --up 192.0.2.254
ipsec whack --trafficstatus
echo done
