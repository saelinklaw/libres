ipsec auto --up north-east-21
ipsec auto --up north-east-22
ipsec auto --up north-east-23
ipsec auto --up north-east-24
ip link show type xfrm
ip addr add 192.0.31.254/24 dev ipsec21 2>/dev/null
ip addr add 192.0.32.254/24 dev ipsec22 2>/dev/null
ip addr add 192.0.33.254/24 dev ipsec23 2>/dev/null
ip addr add 192.0.34.254/24 dev ipsec24 2>/dev/null
../../pluto/bin/ping-once.sh --up -I 192.0.31.254 192.0.21.254
../../pluto/bin/ping-once.sh --up -I 192.0.32.254 192.0.22.254
../../pluto/bin/ping-once.sh --up -I 192.0.33.254 192.0.23.254
../../pluto/bin/ping-once.sh --up -I 192.0.34.254 192.0.24.254
echo done
