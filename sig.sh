#!/bin/bash

file=$1

echo "CSR is $file"

if [ ! -e "$file" ]; then
  echo "Input file not exist"
  read -r -p '>>> Press Entry to exit'
  exit 1
fi

name=${file//\//_}
name=$(echo "$name" | cut -f 1 -d '.')
temp="$name.crt-temp"
cert="$name.crt"
chain="$name-chain.crt"

if [ -e "$cert" ]; then
  echo "Output file already exist"
  read -r -p '>>> Press Entry to exit'
  exit 1
fi

openssl ca -batch \
  -config ca/sub-server/config-sig.ini \
  -policy signing_policy \
  -extensions x509_extensions \
  -out "$temp" \
  -infiles "$file"

openssl x509 -in "$temp" >"$cert"

rm -f "gen/cert-server/$CERT_CN/ssl.crt-temp"

{
  cat "$cert"
  cat "ca/sub-server/cert.crt"
  cat "ca/ca-root/cert.crt"
} >"$chain"
