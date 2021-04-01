/testing/guestbin/swan-prep
cp road-ikev2-oe.conf /etc/ipsec.d/ikev2-oe.conf
cp policies/* /etc/ipsec.d/policies/
echo "192.1.2.0/24"  >> /etc/ipsec.d/policies/private-or-clear
ipsec start
/testing/pluto/bin/wait-until-pluto-started
ipsec whack --impair suppress-retransmits
# ensure for tests acquires expire before our failureshunt=2m
echo 30 > /proc/sys/net/core/xfrm_acq_expires
ipsec whack --listpubkeys
# give OE policies time to load
../../pluto/bin/wait-for.sh --match 'loaded 6,' -- ipsec auto --status
echo "initdone"
