../../pluto/bin/wait-until-alive 192.1.2.254
dig east.testing.libreswan.org
time dig +short east.testing.libreswan.org IPSECKEY
time dig +short @192.1.2.254 east.testing.libreswan.org
dig +short @192.1.2.254 chaos version.server txt
dig +short @192.1.2.254 -p 5353 east.testing.libreswan.org
dig +short @192.1.2.254 -p 5353 chaos version.server txt
echo done
