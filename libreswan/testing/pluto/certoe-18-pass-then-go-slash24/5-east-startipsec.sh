ipsec start
/testing/pluto/bin/wait-until-pluto-started
# give OE policies time to load
../../pluto/bin/wait-for.sh --match 'loaded 11,' -- ipsec auto --status
# trigger OE
ping -c 4 -I 192.1.2.23 192.1.3.209
sleep 1
# traffic minus first packet should have flown through tunnel
ipsec trafficstatus
