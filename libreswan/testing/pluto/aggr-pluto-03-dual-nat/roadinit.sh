/testing/guestbin/swan-prep
ip addr add 192.1.3.210/24 dev eth0
ipsec start
/testing/pluto/bin/wait-until-pluto-started
echo "initdone"
