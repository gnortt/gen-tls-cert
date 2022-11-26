#!/usr/bin/env bash

set -e

usage() {
    echo "Usage: $0 [options] <ca_cn> <server_cn>

    Options:
      -k    diffie-hellman parameter and rsa key size, default 2048 bits
      -l    certificate lifetimes, default 365 days
      -o    output directory, default <server_cn>
      -t    key type (rsa, secp256k1 or secp384r1), default secp384r1"
    exit 1
}

while getopts "k:l:o:t:" flag; do
    case "$flag" in
        k)  KEY_SIZE=$OPTARG;;
        l)  DAYS=$OPTARG;;
        o)  OUT_DIR=$OPTARG;;
        t)  TYPE=$OPTARG;;
        \?) usage;;
    esac
done

shift $((OPTIND - 1))

if [ $# -le 1 ]; then
    usage
fi

CA_CN=$1
SERVER_CN=$2

: "${KEY_SIZE:=2048}"
: "${DAYS:=365}"
: "${OUT_DIR:=$SERVER_CN}"
: "${TYPE:=secp384r1}"

mkdir "$OUT_DIR"
OUT_DIR="$(pwd)/$OUT_DIR"
touch "$OUT_DIR"/index.txt

export KEY_DIR="$OUT_DIR"
echo "[ ca ]
default_ca=ca_default

[ ca_default ]
dir=${OUT_DIR}
certs=\$dir
new_certs_dir=\$dir
database=\$dir/index.txt
serial=\$dir/serial.txt
certificate=\$dir/ca.crt
private_key=\$dir/ca.key
default_days=365
default_md=sha256
preserve=no
policy=policy_default
copy_extensions=copy

[ policy_default ]
countryName=optional
stateOrProvinceName=optional
localityName=optional
organizationName=optional
organizationalUnitName=optional
commonName=supplied
name=optional
emailAddress=optional

[ req ]
default_bits=${KEY_SIZE}
default_keyfile=privkey.key
distinguished_name=req_dn
x509_extensions=v3_ca
string_mask=utf8only

[ req_dn ]
commonName=Common Name
commonName_max=64
commonName_default=${CA_CN}

[ server ]
basicConstraints=CA:FALSE
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid,issuer:always
extendedKeyUsage=serverAuth
keyUsage=digitalSignature,keyEncipherment
nsCertType=server
subjectAltName=${ALT_NAMES}

[ v3_ca ]
basicConstraints=CA:TRUE
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid:always,issuer:always
" > "$OUT_DIR"/openssl.cnf

case "$TYPE" in
    rsa)
        openssl genrsa -out "$OUT_DIR/ca.key" $KEY_SIZE
        openssl genrsa -out "$OUT_DIR/$SERVER_CN.key" $KEY_SIZE
        ;;
    secp384r1|secp256k1) 
        openssl ecparam -genkey -name $TYPE -noout -out "$OUT_DIR/ca.key"
        openssl ecparam -genkey -name $TYPE -noout -out "$OUT_DIR/$SERVER_CN.key"
        ;; 
    *)
        echo "Invalid key type: choose one of rsa, secp256k1 or secp384r1";
        exit 1;;
esac

openssl req \
    -config "$OUT_DIR/openssl.cnf" \
    -batch \
    -nodes \
    -x509 \
    -sha384 \
    -days $DAYS \
    -new \
    -key "$OUT_DIR"/ca.key \
    -out "$OUT_DIR"/ca.crt

export KEY_CN="$SERVER_CN"

openssl req \
    -config "$OUT_DIR/openssl.cnf" \
    -batch \
    -nodes \
    -extensions server \
    -sha384 \
    -new \
    -key "$OUT_DIR/$SERVER_CN.key" \
    -out "$OUT_DIR/$SERVER_CN.csr"

openssl ca \
    -config "$OUT_DIR/openssl.cnf" \
    -batch \
    -notext \
    -rand_serial \
    -extensions server \
    -days $DAYS \
    -in "$OUT_DIR/$SERVER_CN.csr" \
    -out "$OUT_DIR/$SERVER_CN.crt"

openssl dhparam \
    -out "$OUT_DIR/dh$KEY_SIZE.pem" $KEY_SIZE

chmod 0600 "$OUT_DIR"/ca.key
chmod 0600 "$OUT_DIR/$SERVER_CN.key"