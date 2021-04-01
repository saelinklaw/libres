# A tunnel should have established with non-zero byte counters
hostname | grep nic > /dev/null || ipsec whack --trafficstatus
grep "negotiated connection" /tmp/pluto.log
# you should see both RSA and NULL
grep -e 'auth method: ' -e 'hash algorithm identifier' -e ': authenticated using ' OUTPUT/*pluto.log 
: ==== cut ====
ipsec auto --status
: ==== tuc ====
../bin/check-for-core.sh
if [ -f /sbin/ausearch ]; then ausearch -r -m avc -ts recent ; fi
