/testing/guestbin/swan-prep --x509
certutil -D -n road -d sql:/etc/ipsec.d
certutil -D -n north -d sql:/etc/ipsec.d
certutil -D -n east -d sql:/etc/ipsec.d
cp road-ikev2-oe.conf /etc/ipsec.d/ikev2-oe.conf
cp policies/* /etc/ipsec.d/policies/
echo "192.1.2.0/24"  >> /etc/ipsec.d/policies/private-or-clear
restorecon -R /etc/ipsec.d
ipsec start
/testing/pluto/bin/wait-until-pluto-started
ipsec whack --impair suppress-retransmits
# ensure for tests acquires expire before our failureshunt=2m
echo 30 > /proc/sys/net/core/xfrm_acq_expires

# give OE policies time to load
../../pluto/bin/wait-for.sh --match 'loaded 10' -- ipsec auto --status

# one packet, which gets eaten by XFRM, so east does not initiate
../../pluto/bin/ping-once.sh --forget -I 192.1.3.33 192.1.2.23

# wait on OE IKE negotiation
../../pluto/bin/wait-for.sh --match private-or-clear -- ipsec whack --trafficstatus

# ping should succeed through tunnel (road pings once, north twice)
# should show established tunnel and no bare shunts
../../pluto/bin/ping-once.sh --up -I 192.1.3.33 192.1.2.23
../../pluto/bin/ping-once.sh --up -I 192.1.3.33 192.1.2.23
ipsec whack --trafficstatus
ipsec whack --shuntstatus
../../pluto/bin/ipsec-look.sh
iptables -t nat -L -n
