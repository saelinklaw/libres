/testing/guestbin/swan-prep
ipsec start
/testing/pluto/bin/wait-until-pluto-started
ipsec auto --add westnet-eastnet-one
ipsec auto --add westnet-eastnet-two
ipsec auto --add westnet-eastnet-three
echo "initdone"
