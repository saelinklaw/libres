ipsec status | grep eastnet
# should show no hits
hostname | grep nic || grep INVALID_IKE_SPI /tmp/pluto.log
hostname | grep nic || grep MSG_TRUNC /tmp/pluto.log
hostname | grep nic || grep "cannot route" /tmp/pluto.log
hostname | grep nic || grep "retransmitting in response" /tmp/pluto.log
../bin/check-for-core.sh
if [ -f /sbin/ausearch ]; then ausearch -r -m avc -ts recent ; fi
