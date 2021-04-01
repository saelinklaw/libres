../../pluto/bin/ipsec-look.sh
hostname | grep nic > /dev/null || ipsec whack --trafficstatus
# A tunnel should have established
grep "negotiated connection" /tmp/pluto.log
# you should see both RSA and NULL
grep -e 'auth method: ' -e 'hash algorithm identifier' -e ': authenticated using ' /tmp/pluto.log
: ==== cut ====
ipsec auto --status
: ==== tuc ====
../bin/check-for-core.sh
if [ -f /sbin/ausearch ]; then ausearch -r -m avc -ts recent ; fi
