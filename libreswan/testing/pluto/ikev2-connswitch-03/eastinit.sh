/testing/guestbin/swan-prep
certutil -d sql:/etc/ipsec.d -D -n west
ipsec start
/testing/pluto/bin/wait-until-pluto-started
ipsec auto --add westnet-eastnet-one
ipsec auto --add westnet-eastnet-two
ipsec auto --add westnet-eastnet-three
echo "initdone"
