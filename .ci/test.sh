#!/bin/bash -xe

CMD="${0##*/}"
BIN_DIR="${0%/*}"

# make sure we are running from the script locaction
cd "$BIN_DIR"
BIN_DIR="$(pwd)"

./myca.sh clean
./myca.sh create-ca-conf
[ -f ca.conf ] || (echo "ca.conf does not exist" && exit 1)
./myca.sh create-root-ca-key
./myca.sh show-x509 ROOT-CA.pem
./myca.sh create-csr
./myca.sh show-csr foo-server-01.example-domain.com.csr
./myca.sh sign-csr-keep-extensions
./myca.sh show-x509 foo-server-01.example-domain.com.crt
./myca.sh clean
