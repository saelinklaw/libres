ipsec whack --trafficstatus
ip xfrm state
ip xfrm policy
grep "MOBIKE " /tmp/pluto.log
sleep 7
: ==== cut ====
ipsec auto --status
: ==== restore IPs to prevent leaking into other tests that dont reboot first ===
hostname | grep road && (ip addr show dev eth0 | grep 192.1.3.209 || ip addr add 192.1.3.209/24 dev eth0)
: ==== tuc ====
../bin/check-for-core.sh
if [ -f /sbin/ausearch ]; then ausearch -r -m avc -ts recent ; fi
