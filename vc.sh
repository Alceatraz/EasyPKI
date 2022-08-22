#!/bin/bash

[ -z "$CERT_CN" ] && echo 'CERT_CN not set' && exit 1

EXT_C='CN'
EXT_ST='Tianjin'
EXT_L='Tianjin'
EXT_O='BlackTechStudio'
EXT_OU='BlackTechStudio IT department'
EXT_E='root@blacktech.studio'

mkdir -p "gen/cert-client/$CERT_CN"

cat >"gen/cert-client/$CERT_CN/req.ini" <<EOF
HOME = .
[ req ]
default_bits       = 2048
string_mask        = utf8only
req_extensions     = req_extensions
distinguished_name = distinguished_name
[ req_extensions ]
subjectKeyIdentifier = hash
basicConstraints     = critical, CA:true, pathlen:0
keyUsage             = keyCertSign, cRLSign
extendedKeyUsage     = clientAuth
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
commonName                     = Common Name (e.g. client FQDN or YOUR name)
commonName_default             = $CERT_CN
emailAddress                   = Email Address
emailAddress_default           = $EXT_E
EOF

openssl req -batch -newkey rsa -sha256 -nodes -outform PEM \
  -out "gen/cert-client/$CERT_CN/ssl.csr" \
  -keyout "gen/cert-client/$CERT_CN/ssl.key" \
  -config "gen/cert-client/$CERT_CN/req.ini"

openssl ca -batch \
  -config ca/sub-client/config-sig.ini \
  -policy signing_policy \
  -extensions x509_extensions \
  -out "gen/cert-client/$CERT_CN/ssl.crt-temp" \
  -infiles "gen/cert-client/$CERT_CN/ssl.csr"

openssl x509 -in "gen/cert-client/$CERT_CN/ssl.crt-temp" >"gen/cert-client/$CERT_CN/ssl.crt"

rm -f "gen/cert-client/$CERT_CN/ssl.crt-temp"

{
  cat "gen/cert-client/$CERT_CN/ssl.crt"
  cat "ca/sub-client/cert.crt"
  cat "ca/ca-root/cert.crt"
} >"gen/cert-client/$CERT_CN/chain.crt"

openssl pkcs12 -export \
  -inkey "gen/cert-client/$CERT_CN/ssl.key" \
  -in "gen/cert-client/$CERT_CN/chain.crt" \
  -out "gen/cert-client/$CERT_CN/ssl.pfx" \
  -passout pass:
