#!/bin/bash -e
# MIT License
#
# Copyright (c) 2018
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

###############################################################################
# Description: A OpenSSL utility for generating a self signed ROOT CA certs and CSRs.
#
# License: MIT
# Date: 2018-08-24
# Author: Cody Lane
###############################################################################

CMD="${0##*/}"
BIN_DIR="${0%/*}"

# make sure we are running from the script locaction
cd "$BIN_DIR"
BIN_DIR="$(pwd)"

[ -f self-signed-ca-override.conf ] && . self-signed-ca-override.conf
. self-signed-ca-defaults.conf

err() {

  echo "ERR: $* exiting" >&2
  exit 1

}

clean() {

  mkdir -p backups/
  mv ROOT-CA* backups/

  rm -f "${SSL_KEY_DIR}/${SSL_ROOT_CA_KEY}.pem"
  rm -f "${SSL_KEY_DIR}/${SSL_ROOT_CA_KEY}.key"
  rm -f "${SSL_KEY_DIR}/${SSL_ROOT_CA_KEY}.srl"

  rm -f ${SSL_KEY_DIR}/serial*

  rm -f "${SSL_KEY_DIR}/ca.conf"

  rm -f ${SSL_KEY_DIR}/*.crt
  rm -f ${SSL_KEY_DIR}/*.key
  rm -f ${SSL_KEY_DIR}/*.csr

  rm -f ${SSL_KEY_DIR}/index.*

  [ -d "${SSL_KEY_DIR}/newcerts" ] && rm -rf "${SSL_KEY_DIR}/newcerts"
  [ -d "${SSL_KEY_DIR}/private" ] && rm -rf "${SSL_KEY_DIR}/private"
  [ -d "${SSL_KEY_DIR}/ca" ] && rm -rf "${SSL_KEY_DIR}/ca"
  [ -d "${SSL_KEY_DIR}/crl" ] && rm -rf "${SSL_KEY_DIR}/crl"
  [ -d "${SSL_KEY_DIR}/certs" ] && rm -rf "${SSL_KEY_DIR}/certs"

  return 0
}

create-ca-conf() {

  [ -f ${SSL_KEY_DIR}/index.txt ] || touch ${SSL_KEY_DIR}/index.txt
  [ -f ${SSL_KEY_DIR}/serial ] || echo "$(openssl rand -hex 16)" > ${SSL_KEY_DIR}/serial

  mkdir -p ${SSL_KEY_DIR}/newcerts
  mkdir -p ${SSL_KEY_DIR}/ca
  mkdir -p ${SSL_KEY_DIR}/certs
  mkdir -p ${SSL_KEY_DIR}/crl
  mkdir -p ${SSL_KEY_DIR}/private

  echo "$(hostname -f)$(uptime)$(date +%s)" > ${SSL_KEY_DIR}/private/.rand

  cat > ca.conf <<EOF
[ ca ]
default_ca = my_ca

[ my_ca ]
dir               = ${SSL_KEY_DIR}/ca
certs             = ${SSL_KEY_DIR}/certs
crl_dir           = ${SSL_KEY_DIR}/crl
RANDFILE          = ${SSL_KEY_DIR}/private/.rand

#  a text file containing the next serial number to use in hex. Mandatory.
#  This file must be present and contain a valid serial number.
serial = ${SSL_KEY_DIR}/serial

# the text database file to use. Mandatory. This file must be present though
# initially it will be empty.
database = ${SSL_KEY_DIR}/index.txt

# specifies the directory where new certificates will be placed. Mandatory.
new_certs_dir = ${SSL_KEY_DIR}/newcerts
# the file containing the CA certificate. Mandatory
certificate = ${SSL_KEY_DIR}/${SSL_ROOT_CA_KEY}.pem

# the file contaning the CA private key. Mandatory
private_key = ${SSL_KEY_DIR}/${SSL_ROOT_CA_KEY}.key

# For certificate revocation lists.
crlnumber         = ${SSL_KEY_DIR}/crlnumber
crl               = ${SSL_KEY_DIR}/crl/${SSL_ROOT_CA_KEY}.crl.pem
crl_extensions    = crl_ext
default_crl_days  = 30

# the message digest algorithm. Remember to not use MD5 (2018 use sha256)
default_md = ${SSL_KEY_TYPE}

name_opt          = ca_default
cert_opt          = ca_default

# for how many days will the signed certificate be valid
default_days = ${SSL_KEY_EXPIRE_AFTER_DAYS}

# By default we use "user certificate" extensions when signing
# The extentions to add to the cert
x509_extensions = usr_cert

# Extension copying option: use with caution.
copy_extensions = copy

# a section with a set of variables corresponding to DN fields
policy = my_policy

# keep passed DN ordering
preserve = no

[ req ]
default_bits            = ${SSL_ROOT_CA_KEY_SIZE}
default_md              = ${SSL_KEY_TYPE}
distinguished_name      = req_distinguished_name
attributes              = req_attributes
x509_extensions         = v3_ca # The extentions to add to the self signed cert

# Passwords for private keys if not present they will be prompted for
# input_password = secret
# output_password = secret

# This sets a mask for permitted string types. There are several options.
# default: PrintableString, T61String, BMPString.
# pkix   : PrintableString, BMPString (PKIX recommendation before 2004)
# utf8only: only UTF8Strings (PKIX recommendation after 2004).
# nombstr : PrintableString, T61String (no BMPStrings or UTF8Strings).
# MASK:XXXX a literal mask value.
# WARNING: ancient versions of Netscape crash on BMPStrings or UTF8Strings.
string_mask = utf8only

req_extensions = v3_req # The extensions to add to a certificate request

[ req_distinguished_name ]
countryName                     = ${SSL_KEY_COUNTRY}
countryName_default             = ${SSL_KEY_COUNTRY}
countryName_min                 = 2
countryName_max                 = 2

stateOrProvinceName             = State or Province Name (full name)
stateOrProvinceName_default     = ${SSL_KEY_STATE}

localityName                    = Locality Name (eg, city)
localityName_default            = ${SSL_KEY_LOCATION}

0.organizationName              = Organization Name (eg, company)
0.organizationName_default      = ${SSL_KEY_ORG}

# we can do this but it is not needed normally :-)
#1.organizationName             = Second Organization Name (eg, company)
#1.organizationName_default     = World Wide Web Pty Ltd

organizationalUnitName          = Organizational Unit Name (eg, section)
organizationalUnitName_default  = ${SSL_KEY_ORG_UNIT}

commonName                      = Common Name (eg, your name or your server\'s hostname)
commonName_max                  = 64
# commonName_default              = ${SSL_ROOT_CA_CN}

emailAddress                    = Email Address
emailAddress_max                = 64

# SET-ex3                       = SET extension number 3

[ req_attributes ]
challengePassword               = A challenge password
challengePassword_min           = 4
challengePassword_max           = 20

unstructuredName                = An optional company name

[ usr_cert ]
# These extensions are added when 'ca' signs a request.
# This goes against PKIX guidelines but some CAs do it and some software
# requires this to avoid interpreting an end user certificate as a CA.

basicConstraints=CA:FALSE

# Here are some examples of the usage of nsCertType. If it is omitted
# the certificate can be used for anything *except* object signing.

# This is OK for an SSL server.
# nsCertType                    = server

# For an object signing certificate this would be used.
# nsCertType = objsign

# For normal client use this is typical
# nsCertType = client, email
nsCertType = client, email

# and for everything including object signing:
# nsCertType = client, email, objsign

# This is typical in keyUsage for a client certificate.
# keyUsage = nonRepudiation, digitalSignature, keyEncipherment
keyUsage = critical, digitalSignature, keyEncipherment

# This will be displayed in Netscape's comment listbox.
nsComment = "${SSL_KEY_ORG}"

# PKIX recommendations harmless if included in all certificates.
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid,issuer

# This stuff is for subjectAltName and issuerAltname.
# Import the email address.
# subjectAltName=email:copy
# An alternative to produce certificates that aren't
# deprecated according to PKIX.
# subjectAltName=email:move

# Copy subject details
# issuerAltName=issuer:copy

#nsCaRevocationUrl              = http://www.domain.dom/ca-crl.pem
#nsBaseUrl
#nsRevocationUrl
#nsRenewalUrl
#nsCaPolicyUrl
#nsSslServerName

# This is required for TSA certificates.
# extendedKeyUsage = critical,timeStamping
extendedKeyUsage = serverAuth

[ server_cert ]
# Extensions for server certificates (man x509v3_config).
basicConstraints = CA:FALSE
nsCertType = server
nsComment = "${SSL_KEY_ORG}"
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer:always
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth

[ ocsp ]
# Extension for OCSP signing certificates (man ocsp).
basicConstraints = CA:FALSE
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer
keyUsage = critical, digitalSignature
extendedKeyUsage = critical, OCSPSigning

[ crl_ext ]
# Extension for CRLs (man x509v3_config).
authorityKeyIdentifier=keyid:always

[ v3_ca ]
# Extensions for a typical CA
# PKIX recommendation.

subjectKeyIdentifier=hash

authorityKeyIdentifier=keyid:always,issuer

# This is what PKIX recommends but some broken software chokes on critical
# extensions.
basicConstraints = critical,CA:true

# So we do this instead.
# basicConstraints = CA:true

# Key usage: this is typical for a CA certificate. However since it will
# prevent it being used as an test self-signed certificate it is best
# left out by default.
# keyUsage = cRLSign, keyCertSign
keyUsage = critical, digitalSignature, cRLSign, keyCertSign

# Some might want this also
# nsCertType = sslCA, emailCA

# Include email address in subject alt name: another PKIX recommendation
# subjectAltName=email:copy
# Copy issuer details
# issuerAltName=issuer:copy

# DER hex encoding of an extension: beware experts only!
# obj=DER:02:03
# Where 'obj' is a standard or added object
# You can even override a supported extension:
# basicConstraints= critical, DER:30:03:01:01:FF

[ v3_intermediate_ca ]
# Extensions for a typical intermediate CA (man x509v3_config).
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints = critical, CA:true, pathlen:0
keyUsage = critical, digitalSignature, cRLSign, keyCertSign

[ v3_req ]
# Extensions to add to a certificate request
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth

subjectAltName = @alt_names

[ my_policy ]
# if the value is "match" then the field value must match the same field in the
# CA certificate. If the value is "supplied" then it must be present.
# Optional means it may be present. Any fields not mentioned are silently
# deleted.
countryName = optional
stateOrProvinceName = optional
localityName = optional
organizationName = optional
commonName = supplied
organizationalUnitName = optional

[alt_names]
DNS.1 = *.${WILDCARD_DOMAIN}
DNS.2 = ${SSL_KEY_CN}
EOF

COUNTER=3
for alt_name in ${SSL_DNS_ALT_NAMES}
do
  echo "DNS.${COUNTER} = ${alt_name}" >> ca.conf
  COUNTER=$((COUNTER + 1))
done

return $?

}

create-root-ca-key() {
  local _rc=0

  create-ca-conf

  if [ -z "${SSL_ROOT_CA_PASSPHRASE}" ]; then
    # generate ca key without a password
    openssl genrsa -out ${SSL_ROOT_CA_KEY}.key ${SSL_ROOT_CA_KEY_SIZE}
    _rc=$?
    [ ${_rc} -eq 0 ] && echo "OK: generated ${SSL_KEY_DIR}/${SSL_ROOT_CA_KEY}.key without a passphrase" || err "Unable to generate ${SSL_KEY_DIR}/${SSL_ROOT_CA_KEY}.key"

    return $_rc

  else
    # generate ca key with a password
    openssl genrsa -des3 -passout "pass:${SSL_ROOT_CA_PASSPHRASE}" -out ${SSL_ROOT_CA_KEY}.key ${SSL_ROOT_CA_KEY_SIZE}
    _rc=$?
    [ ${_rc} -eq 0 ] && echo "OK: generated ${SSL_KEY_DIR}/${SSL_ROOT_CA_KEY}.key with a passphrase" || err "Unable to generate ${SSL_KEY_DIR}/${SSL_ROOT_CA_KEY}.key"

    return $?
  fi

}

create-root-ca-pem() {

  create-ca-conf

  if [ -z "${SSL_ROOT_CA_PASSPHRASE}" ]; then
    openssl req \
      -config ${SSL_KEY_DIR}/ca.conf \
      -x509 \
      -new \
      -batch \
      -nodes \
      -key ${SSL_KEY_DIR}/${SSL_ROOT_CA_KEY}.key \
      -${SSL_KEY_TYPE} \
      -days ${SSL_ROOT_CA_KEY_EXPIRE_AFTER_DAYS} \
      -out ${SSL_KEY_DIR}/${SSL_ROOT_CA_KEY}.pem

    return $?

  else

    openssl req \
      -config ${SSL_KEY_DIR}/ca.conf \
      -x509 \
      -new \
      -batch \
      -passin "pass:${SSL_ROOT_CA_PASSPHRASE}" \
      -nodes \
      -key ${SSL_KEY_DIR}/${SSL_ROOT_CA_KEY}.key \
      -${SSL_KEY_TYPE} \
      -days ${SSL_KEY_EXPIRE_AFTER_DAYS} \
      -out ${SSL_KEY_DIR}/${SSL_ROOT_CA_KEY}.pem

    return $?

  fi

}

create-csr() {
  local _rc=0

  create-ca-conf

  echo "Generating new key for CSR ..."
  openssl genrsa \
      -out ${SSL_KEY_DIR}/${SSL_KEY_NAME}.key \
      ${SSL_ROOT_CA_KEY_SIZE}
  _rc=$?

  [ ${_rc} -eq 0 ] && echo "OK: generated CSR private key: ${SSL_KEY_DIR}/${SSL_KEY_NAME}.key" || err "Unable to generate CSR private key: ${SSL_KEY_DIR}/${SSL_KEY_NAME}.key"

  echo "Generating CSR ..."
  openssl req \
      -new \
      -key ${SSL_KEY_DIR}/${SSL_KEY_NAME}.key \
      -out ${SSL_KEY_DIR}/${SSL_KEY_NAME}.csr \
      -subj "/C=${SSL_KEY_COUNTRY}/ST=${SSL_KEY_STATE}/L=${SSL_KEY_LOCATION}/O=${SSL_KEY_ORG}/OU=${SSL_KEY_ORG_UNIT}/CN=${SSL_KEY_CN}" \
      -config ${SSL_KEY_DIR}/ca.conf

  [ ${_rc} -eq 0 ] && echo "OK: genereated CSR: ${SSL_KEY_DIR}/${SSL_KEY_NAME}.csr" || err "Unable to generate CSR: ${SSL_KEY_DIR}/${SSL_KEY_NAME}.csr"

  return ${_rc}

}

sign-csr-drop-extensions() {
  local _rc=0

  create-ca-conf

  openssl x509 \
    -req \
    -in ${SSL_KEY_DIR}/${SSL_KEY_NAME}.csr \
    -CA ${SSL_KEY_DIR}/${SSL_ROOT_CA_KEY}.pem \
    -CAkey ${SSL_KEY_DIR}/${SSL_ROOT_CA_KEY}.key \
    -CAcreateserial \
    -out ${SSL_KEY_DIR}/${SSL_KEY_NAME}.crt \
    -days ${SSL_KEY_EXPIRE_AFTER_DAYS} \
    -${SSL_KEY_TYPE}
  _rc=$?

  [ ${_rc} -eq 0 ] && echo "OK: Signed CSR ${SSL_KEY_DIR}/${SSL_KEY_NAME}.crt without extensions"

  return ${_rc}

}

sign-csr-keep-extensions() {
  local _rc=0

  create-ca-conf

  openssl ca \
    -config ${SSL_KEY_DIR}/ca.conf \
    -notext \
    -notext \
    -utf8 \
    -batch \
    -updatedb \
    -out "${SSL_KEY_DIR}/${SSL_KEY_NAME}.crt" \
    -in "${SSL_KEY_DIR}/${SSL_KEY_NAME}.csr"
  _rc=$?

  [ ${_rc} -eq 0 ] && echo "OK: Signed CSR ${SSL_KEY_DIR}/${SSL_KEY_NAME}.crt with extensions"

  return ${_rc}

}

show-x509() {

  [ -f "${1}" ] || err "show-x509 requires a file argument"
  openssl x509 -in ${1} -text -noout

  return $?

}

show-csr() {

  [ -f "${1}" ] || err "show-csr requires a file argument"
  openssl req -in ${1} -text -noout

  return $?

}


usage() {
  echo "USAGE: ${CMD} [action]"
  echo
  echo "[action]"
  echo "clean                          -> WARNING: deletes everything this script creates"
  echo "create-ca-conf                 -> Creates/Overwrite the ${BIN_DIR}/ca.conf"
  echo "create-root-ca-key             -> Create/Overwrite the ${SSL_KEY_DIR}/${SSL_ROOT_CA_KEY}.key"
  echo "create-csr                     -> Create/Overwrite the ${SSL_KEY_DIR}/${SSL_KEY_NAME}.csr"
  echo "sign-csr-drop-extensions       -> Create/Overwrite the ${SSL_KEY_DIR}/${SSL_KEY_NAME}.crt but drop the CSR extensions"
  echo "sign-csr-keep-extensions       -> Create/Overwrite the ${SSL_KEY_DIR}/${SSL_KEY_NAME}.crt but keep the CSR extensions"
  echo "show-x509 [filename.[pem|crt]] -> Show x509 cert info"
  echo "show-csr [filename.[pem|crt]]  -> Show CSR info"

  exit 0
}

## main ##

[ "$#" -eq 0 ] && usage || true

# command line options
while [ -n "${1%%*-}" ]
do

  case "$1" in

    clean)
      clean
    ;;

    create-ca-conf)
      create-ca-conf
    ;;

    create-root-ca-key)
      create-root-ca-key
      create-root-ca-pem
    ;;

    create-csr)
      create-csr
    ;;

    sign-csr-drop-extensions)
      sign-csr-drop-extensions
    ;;

    sign-csr-keep-extensions)
      sign-csr-keep-extensions
    ;;

    show-x509)
      shift

      show-x509 "${1}"
    ;;

    show-csr)
      shift

      show-csr "${1}"
    ;;

    -h|--help|help)
      usage
    ;;

    *)
      echo "Invalid choice: ${1}"
      exit 1
      ;;

  esac

  shift
done

exit $?
