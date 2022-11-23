# gen-tls-cert

Self-signed TLS certificate generator. Quickly create a certificate authority and server key and certificate.

Generated are CA and server `secp384r1` ECC keys, certificates, and Diffie-Hellman parameters (`dh[dh keysize].pem`).

# Requirements

Required dependencies:

- openssl

# Usage

`gen-tls-cert.sh` needs a number of positional arguments:

```
    Usage: ./gen-tls-cert.sh [options] <ca_cn> <server_cn>

        Options:
          -k    diffie-hellman parameter and rsa key size, default 2048 bits
          -l    certificate lifetimes, default 365 days
          -o    output directory, default <server_cn>
          -t    key type (rsa, secp256k1 or secp384r1), default secp384r1

    > ./gen-tls-cert.sh rootCA example.com
    > ls example

    01.pem  ca.key      example.com.crt  example.com.key  index.txt.attr  serial
    ca.crt  dh2048.pem  example.com.csr  index.txt        index.txt.old
```
