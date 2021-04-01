ipsec auto --up road-eastnet
# note this end should be 192.1.3.209
../../pluto/bin/ipsec-look.sh
ping -W 1 -q -n -c 2 -I 192.0.3.10 192.0.2.254
ipsec whack --trafficstatus
sleep 5
# remove this end ip next one will take over
../bin/ip-addr-show.sh
ip route
ip route show scope global | grep 192.1.3.254 && ip route del default via 192.1.3.254
ip addr del 192.1.3.209/24 dev eth0 
# removed address and route
sleep 5
../bin/ip-addr-show.sh
ip route
# add new address and route
ip addr show dev eth0 | grep 192.1.33.209 || ip addr add 192.1.33.209/24 dev eth0
ip route show scope global | grep 192.1.33.254 || ip route add default via 192.1.33.254
# let libreswan detect change and do a MOBIKE update
sleep 10
ping -W 1 -q -n -c 2 -I 192.0.3.10 192.1.2.23
../bin/ip-addr-show.sh
ip route
# MOBIKE ping should work
# note this end should be 192.1.3.209
ping -W 1 -q -n -c 2 -I 192.0.3.10 192.1.2.23
echo done
