# EasyPKI
Simple script generate your PKI.

Recommand for ethernet, Trust the Root-CA then sign your private https, And client auth to your server (Recommand for nginx).

# Usage

- Choose a beautiful place to place those script
- Run `pki.sh`, This will generate Root-CA and Sub-CA
- Run `CERT_CN=test.name.com ./vs.sh`, This will generate Server Cert
- Run `CERT_CN=RD.Jhon Smith ./vc.sh`, This will generate Client Cert
