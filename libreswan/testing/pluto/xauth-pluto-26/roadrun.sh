ipsec whack --xauthname 'xroad' --xauthpass 'use1pass' --name road-east --initiate
../../pluto/bin/ping-once.sh --up 192.0.2.254
ipsec whack --trafficstatus
echo done
