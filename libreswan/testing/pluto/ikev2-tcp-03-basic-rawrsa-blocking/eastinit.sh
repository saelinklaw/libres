/testing/guestbin/swan-prep
ipsec start
/testing/pluto/bin/wait-until-pluto-started
ipsec whack --impair tcp-use-blocking-write
ipsec auto --add westnet-eastnet-ikev2
echo "initdone"
