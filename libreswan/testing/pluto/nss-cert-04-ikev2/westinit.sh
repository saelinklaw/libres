/testing/guestbin/swan-prep --x509 --signedbyother
certutil -d sql:/etc/ipsec.d -D -n east
ipsec start
/testing/pluto/bin/wait-until-pluto-started
ipsec whack --impair suppress-retransmits
ipsec auto --add nss-cert
ipsec auto --status |grep nss-cert
ipsec whack --impair suppress-retransmits
echo "initdone"
