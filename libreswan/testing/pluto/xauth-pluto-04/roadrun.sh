ipsec whack --xauthname 'use2' --xauthpass 'use1pass' --name xauth-road-eastnet-psk --initiate
sleep 5
../../pluto/bin/ping-once.sh --up 192.0.2.254
ipsec whack --trafficstatus
# note there should NOT be any incomplete IKE SA attempting to do ModeCFG or EVENT_RETRANSMIT
ipsec status |grep STATE
echo done
