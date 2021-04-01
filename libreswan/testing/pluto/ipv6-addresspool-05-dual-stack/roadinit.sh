/testing/guestbin/swan-prep --x509 --46
dig +short east46.testing.libreswan.org A
dig +short east46.testing.libreswan.org AAAA
ip -4 route
ip -6 route
../../pluto/bin/wait-until-alive 2001:db8:0:2::254
../../pluto/bin/wait-until-alive 2001:db8:1:2::23
ip route get to 2001:db8:1:2::23
# change the default route
ip -6 route del default
../../pluto/bin/ping-once.sh --down 2001:db8:1:2::23
# add default via link local
ip -6 route add default dev eth0 via fe80::1000:ff:fe32:64ba
../../pluto/bin/ping-once.sh --up 2001:db8:1:2::23
ip6tables -A INPUT -i eth0 -s 2001:db8:0:2::254 -p ipv6-icmp -j DROP
ip6tables -I INPUT -m policy --dir in --pol ipsec -j ACCEPT
../../pluto/bin/ping-once.sh --down 2001:db8:0:2::254
ipsec start
/testing/pluto/bin/wait-until-pluto-started
ipsec whack --impair suppress-retransmits
# this test need --verbose to see source address selection
ipsec auto --add --verbose road
echo "initdone"
