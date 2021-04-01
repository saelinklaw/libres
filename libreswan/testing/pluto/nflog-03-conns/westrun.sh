iptables -L -n
ipsec auto --up westnet-eastnet-nflog
iptables -L -n
ipsec auto --up west-east-nflog
iptables -L -n

# suppress job monitoring; specify packet count
rm -f /tmp/nflog-50.pcap /tmp/tcpdump.log
set +m
tcpdump -c 4 -s 0 -w /tmp/nflog-50.pcap -i nflog:50 > /tmp/tcpdump.log 2>&1 &
../../pluto/bin/wait-for.sh --match 'listening on' -- cat /tmp/tcpdump.log

../../pluto/bin/ping-once.sh --up -I 192.1.2.45 192.1.2.23
../../pluto/bin/ping-once.sh --up -I 192.0.1.254 192.0.2.254
../../pluto/bin/ping-once.sh --up -I 192.1.2.45 192.1.2.23
../../pluto/bin/ping-once.sh --up -I 192.0.1.254 192.0.2.254

ipsec auto --down westnet-eastnet-nflog
iptables -L -n
ipsec auto --down west-east-nflog
iptables -L -n

# wait for count to reach tcpdump then dump it
wait
cp  /tmp/nflog-50.pcap OUTPUT/nflog-50.pcap
tcpdump -n -r OUTPUT/nflog-50.pcap 2>/dev/null

echo done
