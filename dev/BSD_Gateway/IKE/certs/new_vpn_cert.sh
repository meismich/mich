#!/bin/bash
#
# FILE:		new_vpn_cert.sh
#
# Creates a new certificate in the output dir
# Requires CSR in the inpur dir
#
# Argument 1 must be the name of CSR file minus .csr
#


NAME=$1
CERTIP=$2

env CERTIP=$2 \
openssl x509 -req -days 3650 \
	-in input/${NAME}.csr \
	-out output/${NAME}.crt \
	-CA /home/mspence/dev/BSD_Gateway/IKE/certs/ca.crt -CAkey /home/mspence/dev/BSD_Gateway/IKE/certs/private/ca.key -CAcreateserial \
	-extfile /home/mspence/dev/BSD_Gateway/IKE/certs/openssl.cnf \
	-extensions x509v3_IPAddr
