# gen-tls-cert

Self-signed TLS certificate generator script. Quickly generate a certificate authority and server TLS key and certificate.

# Requirements

Required dependencies:

- openssl

# Usage

`gen-tls-cert.sh` needs a number of positional arguments:

```
    Usage: ./gen-tls-cert.sh [output directory] [ca cn] [server cn] [keysize] [days]

    > ./gen-tls-cert.sh example rootCA example.com 2048 365
    > ls example

    01.pem  ca.key           example.com.csr  index.txt       index.txt.old  serial.old
    ca.crt  example.com.crt  example.com.key  index.txt.attr  serial
```
