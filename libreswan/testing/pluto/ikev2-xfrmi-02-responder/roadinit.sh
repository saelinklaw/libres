/testing/guestbin/swan-prep
echo 0 > /proc/sys/net/ipv4/conf/all/rp_filter
ipsec start
/testing/pluto/bin/wait-until-pluto-started
ipsec whack --impair suppress-retransmits
ipsec whack --impair revival
ipsec auto --add road
echo "initdone"
