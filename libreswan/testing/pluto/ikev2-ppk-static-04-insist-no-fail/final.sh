# east should fail PSK because it refuses PPK
hostname | grep east > /dev/null && grep "PSK Authentication failed" /tmp/pluto.log
ipsec whack --shutdown
grep -e leak /tmp/pluto.log | grep -v -e '|'
../bin/check-for-core.sh
if [ -f /sbin/ausearch ]; then ausearch -r -m avc -ts recent ; fi
