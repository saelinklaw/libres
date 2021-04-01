/testing/guestbin/swan-prep --userland strongswan
#../../pluto/bin/wait-until-alive -I 192.0.1.254 192.0.2.254
../../pluto/bin/strongswan-start.sh
ip link set down dev ipsec0 2> /dev/null > /dev/null
ip link del ipsec0 2> /dev/null > /dev/null
#shouldn't charon clean up these two rules ??
ip rule del pref 220 2> /dev/null > /dev/null
ip route del 192.1.2.0/24 dev eth0 table 220 2> /dev/null > /dev/null
ip link add ipsec0 type xfrm if_id 2 dev eth0
# KVM and namespace has this route
ip route del 192.0.1.0/24
ip link set up dev ipsec0
ip route add 192.0.1.0/24 dev ipsec0
swanctl  --load-conns
echo "initdone"
