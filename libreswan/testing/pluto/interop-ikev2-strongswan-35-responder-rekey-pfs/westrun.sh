#sleep 15 seconds,  east is bring up the tunnel
sleep 15
strongswan status
ping -n -s 80 -c  8 -I 192.0.1.254 192.0.2.254
# this should have something like westnet-eastnet-ikev2{3} and no packet loss.
sleep 10 # give strongswan change to remove DELETED, TUNNEL state
strongswan status | grep -v libcurl
echo done
