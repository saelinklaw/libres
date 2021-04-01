iptables -t nat -F
iptables -F
# NAT UDP 500,4500 to NICs address with sport
iptables -t nat -A POSTROUTING -s 192.1.3.0/24 -p udp --sport 4500  -j SNAT --to-source 192.1.2.254:32768-33000
iptables -t nat -A POSTROUTING -s 192.1.3.0/24 -p udp --sport 500  -j SNAT --to-source 192.1.2.254:33001-33101
iptables -t nat -A POSTROUTING -s 192.1.3.0/24 -j SNAT --to-source 192.1.2.254
: ==== end ====
