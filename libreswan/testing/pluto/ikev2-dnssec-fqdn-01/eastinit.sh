/testing/guestbin/swan-prep
ipsec start
/testing/pluto/bin/wait-until-pluto-started
ipsec auto --add road-eastnet
ipsec auto --status
echo "initdone"
