../../pluto/bin/ipsec-look.sh
# on east, it should show it failed the NSS IPsec profile and used the NSS TLS profile
hostname | grep east > /dev/null && grep "verify_end_cert trying profile" /tmp/pluto.log
: ==== cut ====
ipsec auto --status
: ==== tuc ====
../bin/check-for-core.sh
if [ -f /sbin/ausearch ]; then ausearch -r -m avc -ts recent ; fi
