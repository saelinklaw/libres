ipsec auto --up westnet-eastnet-ipv4-psk-ikev1
../../pluto/bin/ping-once.sh --up -I 192.0.1.254 192.0.2.254
echo done
