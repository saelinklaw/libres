# rhbz#1313816
mkdir /tmp/rhbz1313816
rm -f /etc/ipsec.d/*.*
# should abort, not crash, due to missing nss
ipsec pluto --rundir /tmp/rhbz1313816 --nofork --stderrlog --log-no-time
#
# rhbz#1041576 start pluto in dir not owned by root
# should not fail with "pluto: unable to create lock dir:"
# not using /tmp or /var/tmp/ due to specialness of parent dir in test
/testing/guestbin/swan-prep
rm -rf /var/cache/otheruser
mkdir -p /var/cache/otheruser/var/run/pluto /var/cache/otheruser/etc
cp /etc/ipsec.d/*.* /var/cache/otheruser/etc/
mv /etc/ipsec.conf /var/cache/otheruser/etc/
chown -R bin.bin /var/cache/otheruser/var/run/pluto /var/cache/otheruser/etc
chmod -R 755 /var/cache/otheruser
ipsec pluto --rundir /var/cache/otheruser/var/run/pluto --secretsfile /var/cache/otheruser/etc/ipsec.secrets
# give pluto time to start and create its socket and pid files
sleep 3
# show it is running
ipsec whack --rundir /var/cache/otheruser/var/run/pluto --briefstatus
# shut it down
ipsec whack --rundir /var/cache/otheruser/var/run/pluto  --shutdown
echo "initdone"
