# road should have one tunnel, east should have two (from both IPs road used)
ipsec whack --trafficstatus
# check for a counting bug where total SA's is wrong on east
ipsec status | grep 'authenticated'
# verify no packets were dropped due to missing SPD policies
grep -v -P "\t0$" /proc/net/xfrm_stat
: ==== cut ====
ipsec auto --status
: ==== tuc ====
../bin/check-for-core.sh
if [ -f /sbin/ausearch ]; then ausearch -r -m avc -ts recent ; fi
