ipsec whack --impair suppress-retransmits
ipsec whack --impair revival
ipsec auto --add road-east-2
ipsec auto --up road-east-2
../../pluto/bin/ping-once.sh --up -I 192.1.3.209 192.1.2.23
: ==== end ====
