ip addr show dev lo
ip addr show dev eth0
ip addr show dev ipsec1
ip -s link show ipsec1
ip rule show
ip route show
ip route show table 50
../bin/check-for-core.sh
if [ -f /sbin/ausearch ]; then ausearch -r -m avc -ts recent ; fi
