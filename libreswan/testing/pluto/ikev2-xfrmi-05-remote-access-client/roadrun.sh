ipsec auto --up eastnet-any
# did we get our IP
ip addr show dev ipsec1
../../pluto/bin/ping-once.sh --up 192.0.2.254
ipsec whack --trafficstatus
# check to see if our resolv.conf got updated
cat /etc/resolv.conf
# confirm resolv.conf is restored on down
ipsec auto --down eastnet-any
cat /etc/resolv.conf
# did we get our IP cleaned up
ip addr show dev ipsec1
echo done
