/testing/guestbin/swan-prep
ipsec start
/testing/pluto/bin/wait-until-pluto-started
ipsec whack --impair suppress-retransmits
ipsec auto --add northnet-westnet-ipv4-psk
ipsec auto --up northnet-westnet-ipv4-psk
ipsec auto --status
echo "initdone"
