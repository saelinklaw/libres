ipsec auto --up road
# ip rule add prio 100 to 192.1.2.23/32 not fwmark 1/0xffffffff lookup 50
# sleep 2
# ip route add table 50 192.1.2.23/32 dev ipsec0 src 192.1.3.209
../../pluto/bin/ping-once.sh --up 192.1.2.23
ip -s link show ipsec0
ip rule show
ip route show table 50
ip route
# check if_id and mark in ip xfrm state
ip xfrm state
echo done
