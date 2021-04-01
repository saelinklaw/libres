# trigger OE; expect private-or-clear to have no traffic
../../pluto/bin/ping-once.sh --down -I 192.1.3.209 192.1.2.23
../../pluto/bin/wait-for.sh --match private-or-clear -- ipsec whack --trafficstatus
../../pluto/bin/ping-once.sh --up   -I 192.1.3.209 192.1.2.23
# trigger the shunt for 7.*
ipsec whack --shuntstatus
../../pluto/bin/ping-once.sh --down -I 192.1.3.209 7.7.7.7
../../pluto/bin/wait-for.sh --match 7.7.7.7 -- ipsec whack --shuntstatus
../../pluto/bin/ping-once.sh --up   -I 192.1.3.209 7.7.7.7
# wait on OE retransmits and rekeying
sleep 5
ipsec whack --trafficstatus
ipsec whack --shuntstatus
# 7.7.7.7 is %pass, we should be able to ping it
../../pluto/bin/ping-once.sh --up -I 192.1.3.209 7.7.7.7
../../pluto/bin/ipsec-look.sh
# letting acquire and shunt exire
sleep 60
../../pluto/bin/ipsec-look.sh
sleep 60
../../pluto/bin/ipsec-look.sh
sleep 60
../../pluto/bin/ipsec-look.sh
killall ip > /dev/null 2> /dev/null
cp /tmp/xfrm-monitor.out OUTPUT/road.xfrm-monitor.txt
echo done
