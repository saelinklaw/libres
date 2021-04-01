# There should be no established IKE SA and no established IPsec SA
ipsec whack --trafficstatus
# only on east, pluto should be attempting to connect to west because it has auto=start
ipsec status |grep STATE_
# confirm the revive conn code triggered
hostname | grep east > /dev/null && grep -e 'but must remain up per local policy' -e '^[^|].*EVENT_REVIVE_CONNS' /tmp/pluto.log
: ==== cut ====
ipsec auto --status
: ==== tuc ====
../bin/check-for-core.sh
if [ -f /sbin/ausearch ]; then ausearch -r -m avc -ts recent ; fi
