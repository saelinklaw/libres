/testing/guestbin/swan-prep
../../pluto/bin/wait-until-alive -I 192.0.3.254 192.0.2.254

ipsec start
/testing/pluto/bin/wait-until-pluto-started

../bin/block-non-ipsec.sh

ipsec auto --add north-east
ipsec whack --xauthname 'xnorth' --xauthpass 'use1pass' --name north-east --initiate

# note - initiating during "init" when multiple hosts/namespaces are starting up is unwise - race conditions
# let east startup and load conns
sleep 10
ping -q -n -c 4 -w 4 -I 192.0.2.201  192.0.2.254
ipsec whack --trafficstatus
echo initdone
