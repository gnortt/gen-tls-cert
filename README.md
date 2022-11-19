# gen-tls-cert

Self-signed TLS certificate generator. Quickly create a certificate authority and server key and certificate.

Generated are CA and server `secp384r1` ECC keys, certificates, and Diffie-Hellman parameters (`dh[dh keysize].pem`).

# Requirements

Required dependencies:

- openssl

# Usage

`gen-tls-cert.sh` needs a number of positional arguments:

```
    Usage: ./gen-tls-cert.sh [output directory] [ca cn] [server cn] [dh keysize] [days]

    > ./gen-tls-cert.sh example rootCA example.com 2048 365
    > ls example

    01.pem  ca.key      example.com.crt  example.com.key  index.txt.attr  serial
    ca.crt  dh2048.pem  example.com.csr  index.txt        index.txt.old
```
