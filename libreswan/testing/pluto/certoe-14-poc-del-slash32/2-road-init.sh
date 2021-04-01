/testing/guestbin/swan-prep --x509
# add default route over "other" interface. road has only one so we fake one
ip route del default
ip tuntap add mode tun tun0
ifconfig tun0 10.11.12.13/24
ip route add default via 10.11.12.14
ip route add 192.1.2.0/24 via 192.1.3.254
certutil -D -n east -d sql:/etc/ipsec.d
cp road-ikev2-oe.conf /etc/ipsec.d/ikev2-oe.conf
cp policies/* /etc/ipsec.d/policies/
# specific /32 to test replacement of /32 oppo-instance with oppo-group
echo "192.1.2.23/32"  >> /etc/ipsec.d/policies/private-or-clear
restorecon -R /etc/ipsec.d
ipsec start
/testing/pluto/bin/wait-until-pluto-started
ipsec whack --impair suppress-retransmits
# give OE policies time to load
../../pluto/bin/wait-for.sh --match 'loaded 11,' -- ipsec auto --status
ip -s xfrm monitor > /tmp/xfrm-monitor.out &
echo "initdone"
