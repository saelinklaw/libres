# on east this should show 2 sets of in/fwd/out policies
../../pluto/bin/ipsec-look.sh
# check both connections still work on east
ipsec whack --trafficstatus
../../pluto/bin/ping-once.sh --up 192.0.2.101
# so counts do not match
../../pluto/bin/ping-once.sh --up 192.0.2.102
../../pluto/bin/ping-once.sh --up 192.0.2.102
ipsec whack --trafficstatus
