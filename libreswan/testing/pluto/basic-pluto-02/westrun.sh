ipsec auto --up westnet-all
../../pluto/bin/ping-once.sh --up -I 192.0.1.254 192.0.2.254
ipsec trafficstatus
ip route list
# testing re-orienting
ipsec auto --replace westnet-all
ipsec auto --status |grep westnet
echo done
