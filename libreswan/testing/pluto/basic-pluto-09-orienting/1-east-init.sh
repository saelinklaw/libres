/testing/guestbin/swan-prep
ip tunnel add test0 mode gre local 192.1.2.23 remote 192.1.2.45
ip addr add 172.29.1.2/24 dev test0
ip link set dev test0 up
ipsec start
/testing/pluto/bin/wait-until-pluto-started
ipsec auto --add test1
ipsec auto --add test2
ipsec auto --add test3
ipsec auto --ready
