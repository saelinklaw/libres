ipsec auto --up west-east-delete1
../../pluto/bin/ping-once.sh --up -I 192.0.1.254 192.0.2.254
ipsec whack --trafficstatus
ipsec auto --status
echo "sleeping a bit.. 2"
sleep 2
ipsec whack --deletestate 2
echo "sleeping a bit.. 2"
sleep 2
ipsec auto --status
echo "sleeping a bit.. 2"
ipsec whack --deletestate 1
sleep 2
ipsec auto --status
echo done
