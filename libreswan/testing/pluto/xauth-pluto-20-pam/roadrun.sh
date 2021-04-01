ipsec whack --impair suppress-retransmits
ipsec whack --xauthname 'baduser' --xauthpass 'use1pass' --name xauth-road-eastnet --initiate
# prevent revive race, establishing two connections
# prevent false positive on deleting I1 or I2 by redirecting to /dev/null
ipsec auto --add xauth-road-eastnet > /dev/null
ipsec whack --xauthname 'gooduser' --xauthpass 'use1pass' --name xauth-road-eastnet --initiate
../../pluto/bin/ping-once.sh --up 192.0.2.254
ipsec trafficstatus
echo done
