/testing/guestbin/swan-prep
ipsec start
/testing/pluto/bin/wait-until-pluto-started
ipsec auto --add road-east
ipsec auto --add runner-east
echo "initdone"
