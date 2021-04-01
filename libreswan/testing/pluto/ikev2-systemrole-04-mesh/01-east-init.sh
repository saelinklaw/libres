/testing/guestbin/swan-prep
# System Role deployment on nic will push configurations to our machine
# into /etc/ipsec.d/
# because it will change files, we can't mount bind them. So use a fressh empty dir
rm -rf OUTPUT/east/ipsec.d
mkdir -p OUTPUT/east/ipsec.d/policies
chmod 777 OUTPUT/east
mount -o bind,rw OUTPUT/east/ipsec.d /etc/ipsec.d
( cd /etc/ipsec.d/policies; touch private private-or-clear clear block )
# initnss normally happens in the initsystem - but not for namespace testing
#echo $SUDO_COMMAND | grep "/bin/nsenter " > /dev/null 2>&1 && ipsec initnss #> /dev/null
ipsec initnss
/usr/bin/pk12util -i /testing/x509/pkcs12/mainca/east.p12 -d sql:/etc/ipsec.d -w /testing/x509/nss-pw
# test config for syntax errors
ipsec addconn --checkconfig --config /etc/ipsec.conf
# start for test
ipsec start
/testing/pluto/bin/wait-until-pluto-started
# test secrets reading for early warning of syntax errors
ipsec secrets
echo $SUDO_COMMAND | grep "/bin/nsenter " > /dev/null 2>&1 && /usr/sbin/sshd -o PidFile=/var/run/pluto/sshd.pid >/dev/null
# ready for System Role to drop file(s) into /etc/ipsec.d/
echo "initdone"
