#!/usr/bin/env bash

set -e

if [ $# -le 4 ]; then
    echo "Usage: $0 [output directory] [ca cn] [server cn] [keysize] [days]"
    exit 1
fi

OUT_DIR=$1
CA_CN=$2
SERVER_CN=$3
KEY_SIZE=$4
DAYS=$5

mkdir "$OUT_DIR"
OUT_DIR="$(pwd)/$OUT_DIR"

SERIAL=01
echo $SERIAL > "$OUT_DIR"/serial
touch "$OUT_DIR"/index.txt

export KEY_DIR="$OUT_DIR"
export KEY_SIZE=$KEY_SIZE

export KEY_CN="$CA_CN"
openssl req \
    -config "openssl.cnf" \
    -batch \
    -nodes \
    -x509 \
    -new \
    -sha256 \
    -days $DAYS \
    -newkey rsa:$KEY_SIZE \
    -keyout "$OUT_DIR"/ca.key \
    -out "$OUT_DIR"/ca.crt

export KEY_CN="$SERVER_CN"
openssl req \
    -config "openssl.cnf" \
    -batch \
    -nodes \
    -extensions server \
    -new \
    -newkey rsa:$KEY_SIZE \
    -keyout "$OUT_DIR/$SERVER_CN.key" \
    -out "$OUT_DIR/$SERVER_CN.csr"

openssl ca \
    -config "openssl.cnf" \
    -batch \
    -notext \
    -extensions server \
    -md sha256 \
    -days $DAYS \
    -in "$OUT_DIR/$SERVER_CN.csr" \
    -out "$OUT_DIR/$SERVER_CN.crt"
    
chmod 0600 "$OUT_DIR"/ca.key
chmod 0600 "$OUT_DIR/$SERVER_CN.key"