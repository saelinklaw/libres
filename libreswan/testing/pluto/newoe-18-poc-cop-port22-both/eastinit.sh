/testing/guestbin/swan-prep
(test -z $(ip netns identify) || /usr/sbin/sshd -p 22 > /dev/null 2>/dev/null &)
cp east-ikev2-oe.conf /etc/ipsec.d/ikev2-oe.conf
cp policies/* /etc/ipsec.d/policies/
# the order is changed in newoe-18-poc-cop-port22-both-reorder
echo "192.1.3.0/24 tcp 0 22"  >> /etc/ipsec.d/policies/clear-or-private
echo "192.1.3.0/24 tcp 22 0"  >> /etc/ipsec.d/policies/clear-or-private
ipsec start
/testing/pluto/bin/wait-until-pluto-started
# give OE policies time to load
../../pluto/bin/wait-for.sh --match 'loaded 11,' -- ipsec auto --status
echo "initdone"
