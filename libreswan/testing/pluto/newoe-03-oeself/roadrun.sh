# ping my own ips
../../pluto/bin/ping-once.sh --up -I 192.1.3.209 192.1.3.209
sleep 3
../../pluto/bin/ping-once.sh --up -I 192.1.3.209 192.1.3.210
sleep 3
../../pluto/bin/ping-once.sh --up -I 127.0.0.1 127.0.0.1
sleep 3
ipsec whack --shuntstatus
echo done
