#!/usr/bin/env bash

set -e

if [ $# -le 4 ]; then
    echo "Usage: $0 [output directory] [ca cn] [server cn] [dh keysize] [days]"
    exit 1
fi

OUT_DIR=$1
CA_CN=$2
SERVER_CN=$3
KEY_SIZE=$4
DAYS=$5

mkdir "$OUT_DIR"
OUT_DIR="$(pwd)/$OUT_DIR"
touch "$OUT_DIR"/index.txt

export KEY_DIR="$OUT_DIR"
export KEY_CN="$CA_CN"

openssl req \
    -config "openssl.cnf" \
    -batch \
    -noenc \
    -x509 \
    -sha384 \
    -days $DAYS \
    -new \
    -newkey ec:<(openssl ecparam -name secp384r1) \
    -keyout "$OUT_DIR"/ca.key \
    -out "$OUT_DIR"/ca.crt

export KEY_CN="$SERVER_CN"

openssl req \
    -config "openssl.cnf" \
    -batch \
    -noenc \
    -extensions server \
    -sha384 \
    -new \
    -newkey ec:<(openssl ecparam -name secp384r1) \
    -keyout "$OUT_DIR/$SERVER_CN.key" \
    -out "$OUT_DIR/$SERVER_CN.csr"

openssl ca \
    -config "openssl.cnf" \
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