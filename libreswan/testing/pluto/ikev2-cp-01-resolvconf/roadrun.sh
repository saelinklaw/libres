ipsec auto --up eastnet-any
../../pluto/bin/ping-once.sh --up -I 100.64.13.2 192.0.2.254
ipsec whack --trafficstatus
# check to see if our resolv.conf got updated
cat /etc/resolv.conf
# confirm resolv.conf is restored on down
ipsec auto --down eastnet-any
cat /etc/resolv.conf
echo done
