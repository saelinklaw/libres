ipsec whack --xauthname 'use3' --xauthpass 'use1pass' --name modecfg-road-eastnet-psk --initiate
../../pluto/bin/ping-once.sh --up -I 192.0.2.209 192.0.2.254
ipsec whack --trafficstatus
# check to see if our resolv.conf got updated
cat /etc/resolv.conf
# confirm resolv.conf is restored on down
ipsec auto --down modecfg-road-eastnet-psk
cat /etc/resolv.conf
echo done
