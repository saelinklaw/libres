ip route get to 192.0.2.254 | grep eth1 && ip route del 192.0.2.0/24 via 192.1.2.23 dev eth1
/testing/guestbin/swan-prep
ipsec start
/testing/pluto/bin/wait-until-pluto-started
ipsec auto --add westnet-eastnet
ipsec auto --up westnet-eastnet
ping -w 10 -n -c 2 -I 192.0.1.254 192.0.2.254
echo "initdone"
