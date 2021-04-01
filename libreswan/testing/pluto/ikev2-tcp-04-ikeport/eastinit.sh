/testing/guestbin/swan-prep --x509
certutil -D -n west -d sql:/etc/ipsec.d
ipsec start
/testing/pluto/bin/wait-until-pluto-started
ipsec auto --add ikev2-westnet-eastnet
# block all TCP and UDP port 500 and 4500
iptables -I INPUT -p udp --dport 500 -j DROP
iptables -I INPUT -p udp --dport 4500 -j DROP
iptables -I INPUT -p tcp --dport 4500 -j DROP
echo "initdone"
