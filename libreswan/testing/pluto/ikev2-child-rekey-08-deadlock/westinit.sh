/testing/guestbin/swan-prep
ipsec start
/testing/pluto/bin/wait-until-pluto-started
ipsec whack --impair revival
ipsec auto --add west
sleep 4
echo "initdone"
