/testing/guestbin/swan-prep
cp policies/* /etc/ipsec.d/policies/
cp east-ikev2-oe.conf /etc/ipsec.d/ikev2-oe.conf
echo "192.1.3.0/24"  >> /etc/ipsec.d/policies/private-or-clear
ipsec start
/testing/pluto/bin/wait-until-pluto-started
# give OE policies time to load
../../pluto/bin/wait-for.sh --match 'loaded 10,' -- ipsec auto --status
echo "initdone"
