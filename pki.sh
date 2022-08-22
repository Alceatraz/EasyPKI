#!/bin/bash

EXT_C='CN'
EXT_ST='Tianjin'
EXT_L='Tianjin'
EXT_O='BlackTechStudio'
EXT_OU='BTStudio IT Dept.'
EXT_CN='BTStudio PKI System'
EXT_E='root@blacktech.studio'

rm -rf ca

if [ -e 'ca' ] && [ -e 'ca/lock.txt' ]; then
  echo 'Cancel: File lock.txt exist, Delete it if you want to regen PKI.'
  exit 1
fi

mkdir ca

mkdir ca/conf
mkdir ca/temp

mkdir ca/ca-root
mkdir ca/sub-server
mkdir ca/sub-client

mkdir ca/ca-root/output
mkdir ca/sub-client/output
mkdir ca/sub-server/output

touch ca/ca-root/index.txt
touch ca/sub-client/index.txt
touch ca/sub-server/index.txt

echo '01' >ca/ca-root/serial.txt
echo '01' >ca/sub-client/serial.txt
echo '01' >ca/sub-server/serial.txt

cat >ca/ca-root/config-req.ini <<EOF
HOME = .
[ ca ]
default_ca = @default_ca
[ default_ca ]
preserve         = no
default_days     = 18250
default_crl_days = 30
default_md       = sha256
x509_extensions  = x509_extensions
email_in_dn      = no
copy_extensions  = copy
[ req ]
default_bits       = 2048
string_mask        = utf8only
x509_extensions    = x509_extensions
distinguished_name = distinguished_name
[ x509_extensions ]
subjectKeyIdentifier   = hash
basicConstraints       = critical, CA:true
authorityKeyIdentifier = keyid:always, issuer:always
keyUsage               = keyCertSign, cRLSign
[ distinguished_name ]
countryName                    = Country Name (2 letter code)
countryName_default            = $EXT_C
stateOrProvinceName            = State or Province Name (full name)
stateOrProvinceName_default    = $EXT_ST
localityName                   = Locality Name (eg, city)
localityName_default           = $EXT_L
organizationName               = Organization Name (eg, company)
organizationName_default       = $EXT_O
organizationalUnitName         = Organizational Unit (eg, division)
organizationalUnitName_default = $EXT_OU
commonName                     = Common Name (e.g. server FQDN or YOUR name)
commonName_default             = Root CA of $EXT_CN
emailAddress                   = Email Address
emailAddress_default           = $EXT_E
EOF

cat >ca/ca-root/config-sig.ini <<EOF
HOME = .
[ ca ]
default_ca = default_ca
[ default_ca ]
preserve         = no
default_days     = 18250
default_crl_days = 30
default_md       = sha256
email_in_dn      = no
unique_subject   = no
copy_extensions  = copy
x509_extensions  = x509_extensions
base_dir         = .
certificate      = ca/ca-root/cert.crt
private_key      = ca/ca-root/cert.key
new_certs_dir    = ca/ca-root/output
database         = ca/ca-root/index.txt
serial           = ca/ca-root/serial.txt
[ signing_policy ]
countryName            = supplied
stateOrProvinceName    = supplied
localityName           = supplied
organizationName       = supplied
organizationalUnitName = supplied
commonName             = supplied
emailAddress           = supplied
[ x509_extensions ]
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid:always, issuer:always
basicConstraints       = critical, CA:true, pathlen:0
keyUsage               = keyCertSign, cRLSign
EOF

cat >ca/sub-server/config-req.ini <<EOF
HOME = .
[ req ]
default_bits       = 2048
string_mask        = utf8only
req_extensions     = req_extensions
distinguished_name = distinguished_name
[ distinguished_name ]
countryName                    = Country Name (2 letter code)
countryName_default            = $EXT_C
stateOrProvinceName            = State or Province Name (full name)
stateOrProvinceName_default    = $EXT_ST
localityName                   = Locality Name (eg, city)
localityName_default           = $EXT_L
organizationName               = Organization Name (eg, company)
organizationName_default       = $EXT_O
organizationalUnitName         = Organizational Unit (eg, division)
organizationalUnitName_default = $EXT_OU
commonName                     = Common Name (e.g. server FQDN or YOUR name)
commonName_default             = Intermediate Server CA of $EXT_CN
emailAddress                   = Email Address
emailAddress_default           = $EXT_E
[ req_extensions ]
subjectKeyIdentifier = hash
basicConstraints     = critical, CA:true, pathlen:0
keyUsage             = keyCertSign, cRLSign
EOF

cat >ca/sub-server/config-sig.ini <<EOF
HOME = .
[ ca ]
default_ca = default_ca
[ default_ca ]
preserve         = no
default_days     = 18250
default_crl_days = 30
default_md       = sha256
x509_extensions  = x509_extensions
email_in_dn      = no
unique_subject   = no
copy_extensions  = copy
base_dir         = .
certificate      = ca/sub-server/cert.crt
private_key      = ca/sub-server/cert.key
new_certs_dir    = ca/sub-server/output
database         = ca/sub-server/index.txt
serial           = ca/sub-server/serial.txt
[ signing_policy ]
countryName            = supplied
stateOrProvinceName    = supplied
localityName           = supplied
organizationName       = supplied
organizationalUnitName = supplied
commonName             = supplied
emailAddress           = supplied
[ x509_extensions ]
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid:always, issuer:always
basicConstraints       = CA:false
keyUsage               = keyEncipherment
extendedKeyUsage       = serverAuth
EOF

cat >ca/sub-client/config-req.ini <<EOF
HOME = .
[ req ]
default_bits       = 2048
string_mask        = utf8only
req_extensions     = req_extensions
distinguished_name = distinguished_name
[ distinguished_name ]
countryName                    = Country Name (2 letter code)
countryName_default            = $EXT_C
stateOrProvinceName            = State or Province Name (full name)
stateOrProvinceName_default    = $EXT_ST
localityName                   = Locality Name (eg, city)
localityName_default           = $EXT_L
organizationName               = Organization Name (eg, company)
organizationName_default       = $EXT_O
organizationalUnitName         = Organizational Unit (eg, division)
organizationalUnitName_default = $EXT_OU
commonName                     = Common Name (e.g. server FQDN or YOUR name)
commonName_default             = Intermediate Client CA of $EXT_CN
emailAddress                   = Email Address
emailAddress_default           = $EXT_E
[ req_extensions ]
subjectKeyIdentifier = hash
basicConstraints     = critical, CA:true, pathlen:0
keyUsage             = keyCertSign, cRLSign
EOF

cat >ca/sub-client/config-sig.ini <<EOF
HOME = .
[ ca ]
default_ca = default_ca
[ default_ca ]
preserve         = no
default_days     = 18250
default_crl_days = 30
default_md       = sha256
x509_extensions  = x509_extensions
email_in_dn      = no
unique_subject   = no
copy_extensions  = copy
base_dir         = .
certificate      = ca/sub-client/cert.crt
private_key      = ca/sub-client/cert.key
new_certs_dir    = ca/sub-client/output
database         = ca/sub-client/index.txt
serial           = ca/sub-client/serial.txt
[ signing_policy ]
countryName            = supplied
stateOrProvinceName    = supplied
localityName           = supplied
organizationName       = supplied
organizationalUnitName = supplied
commonName             = supplied
emailAddress           = supplied
[ x509_extensions ]
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid:always, issuer:always
basicConstraints       = CA:false
keyUsage               = keyEncipherment
extendedKeyUsage       = clientAuth
EOF

echo '>>> Create Root CA'

openssl req -batch -nodes -sha256 -outform PEM -newkey rsa -x509 \
  -out ca/ca-root/cert.crt \
  -keyout ca/ca-root/cert.key \
  -config ca/ca-root/config-req.ini

echo '>>> Create Server CSR'

openssl req -batch -nodes -sha256 -outform PEM -newkey rsa \
  -out ca/sub-server/cert.csr \
  -keyout ca/sub-server/cert.key \
  -config ca/sub-server/config-req.ini

echo '>>> Create Server CRT'

openssl ca -batch \
  -policy signing_policy \
  -extensions x509_extensions \
  -config ca/ca-root/config-sig.ini \
  -out ca/temp/sub-server.crt \
  -infiles ca/sub-server/cert.csr

{
  openssl x509 -in ca/temp/sub-server.crt
  cat ca/ca-root/cert.crt
} >ca/sub-server/cert.crt

echo '>>> Create Client CSR'

openssl req -batch -nodes -sha256 -outform PEM -newkey rsa \
  -out ca/sub-client/cert.csr \
  -keyout ca/sub-client/cert.key \
  -config ca/sub-client/config-req.ini

echo '>>> Create Client CRT'

openssl ca -batch \
  -policy signing_policy \
  -extensions x509_extensions \
  -config ca/ca-root/config-sig.ini \
  -out ca/temp/sub-client.crt \
  -infiles ca/sub-client/cert.csr

openssl x509 -in ca/temp/sub-client.crt >ca/sub-client/cert.crt

{
  cat ca/sub-client/cert.crt
  cat ca/ca-root/cert.crt
} >ca/sub-client/chain.crt

echo 'This file is a flag. Deny reinstall PKI when exist.' >ca/lock.txt

echo '>>> Done!'
