# there should be only one pub key not road.
ipsec auto --listpubkeys
ipsec auto --up road-east-1
# there should be two public keys. including road
../../pluto/bin/ping-once.sh --up -I 192.1.3.209 192.1.2.23
ipsec whack --trafficstatus
ipsec auto --listpubkeys
#restart with new keys
cp road-2.secrets /etc/ipsec.secrets
ipsec stop
sleep 2
ipsec start
/testing/pluto/bin/wait-until-pluto-started
ipsec whack --impair suppress-retransmits
ipsec whack --impair revival
ipsec auto --add road-east-2
# expected to succeed !
ipsec auto --up road-east-2
../../pluto/bin/ping-once.sh --up -I 192.1.3.209 192.1.2.23
echo done
