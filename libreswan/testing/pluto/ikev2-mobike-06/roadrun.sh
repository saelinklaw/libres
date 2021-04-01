ipsec auto --up road-eastnet
ping -W 1 -q -n -c 2 192.1.2.23
ipsec whack --trafficstatus
# note this end should be 192.1.3.209
ip xfrm state
ip xfrm policy
sleep 5
# remove this end ip next one will take over
ip addr show scope global dev eth0 | grep -v valid_lft
# delete the routes down to simulate WiFi link down.
ip addr del 192.1.3.209/24 dev eth0
ip route del default via 192.1.3.254 dev eth0
sleep 2
ip addr add 192.1.33.222/24 dev eth0
sleep 2
# the client is still on the dev lo.
# would the traffic leak in plain
# let libreswan detect change and initiate MOBIKE update
ip route add default via 192.1.33.254 dev eth0
sleep 10
# ip addr show scope global dev eth0 | grep -v -E '(valid_lft|ether|noqueue)'
ip addr show scope global dev eth0 | grep -v valid_lft
# MOBIKE ping should work
ping -W 8 -q -n -c 8 192.1.2.23
# "ip xfrm" output this end should be 192.1.33.222
echo done
