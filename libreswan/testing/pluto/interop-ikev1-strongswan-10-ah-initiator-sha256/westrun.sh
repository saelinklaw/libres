strongswan up westnet-eastnet-ikev1
../../pluto/bin/ping-once.sh --up -I 192.0.1.254 192.0.2.254
# cannot use ../../pluto/bin/ipsec-look.sh for strongswan
ip xfrm state
ip xfrm policy
echo done
