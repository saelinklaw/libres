ipsec auto --up west
# route is not installed both letfsubnet=rightsubnet
../../pluto/bin/ping-once.sh --down -I 192.0.1.254 192.0.2.254
# add route
ip addr add 192.0.1.254/24 dev ipsec1
ip route add 192.0.2.0/24 dev ipsec1
ping -w 4 -n -c 2 -I 192.0.1.254 192.0.2.254
ip -s link show ipsec1
echo done
