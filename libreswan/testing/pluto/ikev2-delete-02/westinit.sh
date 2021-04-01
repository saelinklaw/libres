/testing/guestbin/swan-prep
# confirm that the network is alive
../../pluto/bin/ping-once.sh --up -I 192.0.1.254 192.0.2.254
# ensure that clear text does not get through
iptables -A INPUT -i eth1 -s 192.0.2.0/24 -j DROP
iptables -I INPUT -m policy --dir in --pol ipsec -j ACCEPT
# confirm clear text does not get through
../../pluto/bin/ping-once.sh --down -I 192.0.1.254 192.0.2.254
ipsec start
/testing/pluto/bin/wait-until-pluto-started
ipsec auto --add west-east-delete1
ipsec whack --impair suppress-retransmits
ipsec whack --impair revival
echo "initdone"
