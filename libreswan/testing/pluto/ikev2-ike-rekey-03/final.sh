ipsec whack --trafficstatus
ipsec status |grep STATE_ | sort
# there should be only one IKE_INIT exchange created on west
hostname | grep west > /dev/null && grep "sent IKE_SA_INIT request" /tmp/pluto.log
: ==== cut ====
ipsec auto --status
: ==== tuc ====
../bin/check-for-core.sh
if [ -f /sbin/ausearch ]; then ausearch -r -m avc -ts recent ; fi
