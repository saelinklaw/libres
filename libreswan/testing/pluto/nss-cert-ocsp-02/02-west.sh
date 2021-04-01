/testing/guestbin/swan-prep --x509 --revoked
certutil -d sql:/etc/ipsec.d -D -n east
ipsec start
/testing/pluto/bin/wait-until-pluto-started
ipsec whack --impair delete-on-retransmit
ipsec whack --impair revival
ipsec auto --add nss-cert-ocsp
ipsec auto --status |grep nss-cert-ocsp
echo "initdone"
ipsec auto --up nss-cert-ocsp
echo done
