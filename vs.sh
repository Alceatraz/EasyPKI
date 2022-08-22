#!/bin/bash

[ -z "$CERT_CN" ] && echo 'CERT_CN not set' && exit 1

EXT_C='CN'
EXT_ST='Tianjin'
EXT_L='Tianjin'
EXT_O='BlackTechStudio'
EXT_OU='BlackTechStudio IT department'
EXT_E='root@blacktech.studio'

mkdir -p "gen/cert-server/$CERT_CN"

cat >"gen/cert-server/$CERT_CN/req.ini" <<EOF
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
extendedKeyUsage     = serverAuth
subjectAltName       = @alternate_names
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
commonName_default             = $CERT_CN
emailAddress                   = Email Address
emailAddress_default           = $EXT_E
[ alternate_names ]
EOF

[ -z "$CERT_CN_1" ] && CERT_CN_1=$CERT_CN
[ -n "$CERT_CN_1" ] && echo "DNS.1=$CERT_CN_1" >>"gen/cert-server/$CERT_CN/req.ini"
[ -n "$CERT_CN_2" ] && echo "DNS.2=$CERT_CN_2" >>"gen/cert-server/$CERT_CN/req.ini"
[ -n "$CERT_CN_3" ] && echo "DNS.3=$CERT_CN_3" >>"gen/cert-server/$CERT_CN/req.ini"
[ -n "$CERT_CN_4" ] && echo "DNS.4=$CERT_CN_4" >>"gen/cert-server/$CERT_CN/req.ini"
[ -n "$CERT_IP_1" ] && echo "IP.1=$CERT_IP_1" >>"gen/cert-server/$CERT_CN/req.ini"
[ -n "$CERT_IP_2" ] && echo "IP.2=$CERT_IP_2" >>"gen/cert-server/$CERT_CN/req.ini"
[ -n "$CERT_IP_3" ] && echo "IP.3=$CERT_IP_3" >>"gen/cert-server/$CERT_CN/req.ini"
[ -n "$CERT_IP_4" ] && echo "IP.4=$CERT_IP_4" >>"gen/cert-server/$CERT_CN/req.ini"

openssl req -batch -newkey rsa -sha256 -nodes -outform PEM \
  -out "gen/cert-server/$CERT_CN/ssl.csr" \
  -keyout "gen/cert-server/$CERT_CN/ssl.key" \
  -config "gen/cert-server/$CERT_CN/req.ini"

openssl ca -batch \
  -config ca/sub-server/config-sig.ini \
  -policy signing_policy \
  -extensions x509_extensions \
  -out "gen/cert-server/$CERT_CN/ssl.crt-temp" \
  -infiles "gen/cert-server/$CERT_CN/ssl.csr"

openssl x509 -in "gen/cert-server/$CERT_CN/ssl.crt-temp" >"gen/cert-server/$CERT_CN/ssl.crt"

rm -f "gen/cert-server/$CERT_CN/ssl.crt-temp"

{
  cat "gen/cert-server/$CERT_CN/ssl.crt"
  cat "ca/sub-server/cert.crt"
  cat "ca/ca-root/cert.crt"
} >"gen/cert-server/$CERT_CN/chain.crt"

openssl pkcs12 -export \
  -inkey "gen/cert-server/$CERT_CN/ssl.key" \
  -in "gen/cert-server/$CERT_CN/chain.crt" \
  -out "gen/cert-server/$CERT_CN/ssl.pfx" \
  -passout pass:
