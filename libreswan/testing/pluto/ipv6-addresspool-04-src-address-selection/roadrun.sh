ipsec auto --up road
ping6 -c 2 -w 5 -I 2001:db8:0:3:1::0 2001:db8:0:2::254
ipsec trafficstatus 
../../pluto/bin/ip-addr-show.sh
ip -6 route
ip route get to 2001:db8:1:2::23
#
# addconn need a non existing --ctlsocket 
# otherwise this add bring the connection down.
#
# see the source address selection when the tunnel is established
ipsec auto --add --verbose --ctlsocket /run/pluto/foo road
echo done
