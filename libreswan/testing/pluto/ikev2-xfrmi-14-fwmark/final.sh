ipsec whack --trafficstatus
# this will succeed on west and north and error on east
hostname | grep west > /dev/null && ip -s link show dev gre1
hostname | grep north > /dev/null && ip -s link show dev gre1
: ==== cut ====
ipsec auto --status
: ==== tuc ====
../bin/check-for-core.sh
if [ -f /sbin/ausearch ]; then ausearch -r -m avc -ts recent ; fi
