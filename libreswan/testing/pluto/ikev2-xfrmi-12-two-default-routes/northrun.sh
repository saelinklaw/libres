ipsec auto --up north-west
ip -s link show ipsec2
ip route add 192.0.1.0/24 dev ipsec2
ping -w 4 -c 4 192.0.1.254
ip -s link show ipsec2
ipsec trafficstatus
# second connection will fail
ipsec auto --up north-east
ip -s link show ipsec2
ip route add 192.0.2.0/24 dev ipsec3
ping -w 4 -c 4 192.0.2.254
ip -s link show ipsec3
ipsec trafficstatus
echo "initdone"
