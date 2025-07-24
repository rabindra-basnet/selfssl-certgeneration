#!/bin/bash

# Create directory for certificates
mkdir certs && cd certs

# Generate CA private key
openssl genrsa -out ca.key 2048

# Generate CA certificate
openssl req -x509 -new -nodes -key ca.key -sha256 -days 3650 -out ca.crt \
-subj "/C=NP/ST=Kathmandu/L=Kathmandy/O=Trading/OU=Rabindra/CN=domain_name/emailAddress=email_address"

# Generate server private key
openssl genrsa -out server.key 2048

# Create OpenSSL configuration file for SAN
cat > openssl-san.cnf <<EOL
[req]
default_bits = 2048
prompt = no
default_md = sha256
req_extensions = req_ext
distinguished_name = dn

[dn]
C = NP
ST = Kathmandu
L = Kathmandy
O = Trading
OU = Rabindra
CN = 192.168.10.41
emailAddress = rabindraabasnet@gmail.com

[req_ext]
subjectAltName = @alt_names

[alt_names]
IP.1 = domain_name
EOL

# Generate server CSR
openssl req -new -key server.key -out server.csr -config openssl-san.cnf

# Sign server certificate with CA
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial \
-out server.crt -days 365 -sha256 -extfile openssl-san.cnf -extensions req_ext

echo "Certificates generated in the 'certs' directory:"
ls -l
