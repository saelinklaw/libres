/testing/guestbin/swan-prep
ip tunnel add eth3 mode gre local 192.1.2.45 remote 192.1.2.23
ip addr add 192.1.3.2/24 dev eth3
ip link set dev eth3 up
ipsec start
/testing/pluto/bin/wait-until-pluto-started
ipsec auto --add test1
ipsec auto --add test2
ipsec auto --add test3
ipsec auto --status | grep interface
ipsec auto --status | grep orient
