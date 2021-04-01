/testing/guestbin/swan-prep  --x509
certutil -D -n road -d sql:/etc/ipsec.d
cp east-ikev2-oe.conf /etc/ipsec.d/ikev2-oe.conf
cp policies/* /etc/ipsec.d/policies/
echo "192.1.3.0/24"  >> /etc/ipsec.d/policies/clear-or-private
ipsec restart
/testing/pluto/bin/wait-until-pluto-started
ipsec whack --impair suppress-retransmits
# give OE policies time to load
../../pluto/bin/wait-for.sh --match 'loaded 3' -- ipsec auto --status
echo "initdone"
