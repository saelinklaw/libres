strongswan up westnet-eastnet-ikev2 | grep -v libcurl
../../pluto/bin/ping-once.sh --up -I 192.0.1.254 192.0.2.254
# hash algorithm notification should NOT be received
grep SIGNATURE_HASH_ALGO /tmp/charon.log | cut -f 2 -d "]" 
echo done
