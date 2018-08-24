[![Build Status](https://travis-ci.org/codylane/openssl-self-signed-ca.svg?branch=master)](https://travis-ci.org/codylane/openssl-self-signed-ca)

How to use Openssl to be a self signed CA
-----------------------------------------

Helpful Links
-------------

- https://jamielinux.com/docs/openssl-certificate-authority/sign-server-and-client-certificates.html
- https://gist.github.com/Soarez/9688998
- https://www.madboa.com/geek/openssl/#cert-self
- https://datacenteroverlords.com/2012/03/01/creating-your-own-ssl-certificate-authority/



Create a default config with the following contents
---------------------------------------------------

```
cd self-signed-ca

cat > self-signed-ca-override.conf <<EOF
WILDCARD_DOMAIN="example-domain.com"

SSL_ROOT_CA_KEY_SIZE="2048"

SSL_KEY_CN="foo-server-01.\${WILDCARD_DOMAIN}"
SSL_KEY_EXPIRE_AFTER_DAYS="365"
SSL_KEY_COUNTRY="US"
SSL_KEY_STATE="FOO"
SSL_KEY_LOCATION="BAR"

. self-signed-ca-defaults.conf
EOF
```

Create the ca.conf
--------------------

```
./myca.sh create-ca-conf
```

Create the ROOT-CA key pair
---------------------------

```
./myca.sh create-root-ca-key
```

* OR create the ROOT-CA key pair with a passphrase

```
SSL_ROOT_CA_PASSPHRASE="$(read -sp "enter passphrase >>> " SSL_ROOT_CA_PASSPHRASE; echo $SSL_ROOT_CA_PASSPHRASE)" ./myca.sh create-root-ca-key
```

Validate your ROOT-CA certificate
---------------------------------

#### `./myca.sh show-x509 ROOT-CA.pem`

```
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number: 18122428188057182289 (0xfb7fcc6b98aca051)
    Signature Algorithm: sha256WithRSAEncryption
        Issuer: C=US, ST=FOO, L=BAR, O=Self Signed OpenSSL CA Cert, OU=Engineering
        Validity
            Not Before: Aug 24 18:00:19 2018 GMT
            Not After : Aug 24 18:00:19 2019 GMT
        Subject: C=US, ST=FOO, L=BAR, O=Self Signed OpenSSL CA Cert, OU=Engineering
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (2048 bit)
                Modulus:
                    00:e5:c4:c2:7c:46:8d:f8:46:04:66:ed:88:53:b8:
                    e0:23:4a:5c:0e:30:01:e3:fa:2f:3e:3a:77:c0:0c:
                    c5:a2:8e:7b:8e:e0:56:c8:06:cd:82:34:91:b1:48:
                    2d:07:28:d1:2e:05:80:8d:4f:6e:c5:f1:3e:55:dd:
                    fb:90:81:dc:4c:c3:5e:e5:49:fa:4e:55:d6:f9:47:
                    23:e4:b7:ae:8d:a6:8c:82:1a:c9:55:43:ac:84:3e:
                    3e:ca:1c:1e:0b:3b:47:53:68:d3:83:4e:6e:16:cb:
                    d4:80:a2:d8:e0:2b:db:4c:45:b0:75:2a:88:0d:0e:
                    6d:06:af:67:9a:b1:0a:7c:5f:82:ba:4e:1f:9a:4d:
                    b8:0c:c6:fd:d8:fc:e2:53:ba:6f:85:1b:76:4d:77:
                    75:30:ad:a4:5e:2e:e2:c0:43:87:74:04:c8:7e:26:
                    40:a6:b5:10:0d:d0:dc:bf:15:ac:ec:b6:b2:33:5f:
                    79:02:5c:85:78:8a:f5:e5:2b:c9:61:46:ff:4a:83:
                    ab:6f:3c:21:0a:f0:03:fe:ce:ca:59:96:91:4b:04:
                    d4:ff:a3:c8:ae:6e:e9:a3:21:e7:76:ee:64:6c:ed:
                    8a:27:4f:ef:53:0f:a2:7d:be:56:fd:65:ef:8f:a7:
                    9b:11:8d:19:d3:a0:14:d7:12:56:cc:99:de:54:28:
                    98:8f
                Exponent: 65537 (0x10001)
        X509v3 extensions:
            X509v3 Subject Key Identifier:
                6B:CE:E2:49:73:30:B0:46:B3:25:A2:8F:4F:2A:95:FE:1B:53:37:68
            X509v3 Authority Key Identifier:
                keyid:6B:CE:E2:49:73:30:B0:46:B3:25:A2:8F:4F:2A:95:FE:1B:53:37:68

            X509v3 Basic Constraints: critical
                CA:TRUE
            X509v3 Key Usage: critical
                Digital Signature, Certificate Sign, CRL Sign
    Signature Algorithm: sha256WithRSAEncryption
         31:a3:fd:a1:6b:96:54:a6:d9:7a:f3:81:db:14:66:a5:53:e1:
         66:00:55:9a:e6:65:69:0b:92:a0:3b:0c:d7:32:d2:5b:4e:82:
         b8:87:6c:57:5f:5f:76:46:84:c8:9e:8d:22:36:df:43:d5:cf:
         4f:e6:ed:16:9a:05:dd:d5:7f:a9:23:09:e6:61:a8:4c:a6:a1:
         88:e4:71:ba:bb:a9:88:bf:e5:8b:81:cf:67:74:af:a6:6a:4e:
         e3:91:e4:3e:b3:fb:a3:23:cb:61:c5:2b:6d:63:de:ee:a5:e6:
         6b:4f:4b:83:d6:5b:67:c9:e5:fe:bd:1c:34:eb:6c:e5:7d:7c:
         3b:6a:7e:a2:83:04:f3:e6:23:0a:33:8a:f9:2e:2f:d3:aa:cb:
         a2:45:09:e3:be:c5:b3:43:95:7d:e7:46:cf:3b:12:b3:a0:15:
         3a:ce:c6:f0:8c:bf:a7:ba:13:85:10:de:ce:90:0c:21:cb:5b:
         17:9c:5d:22:c6:e5:e6:ca:a4:32:5e:1a:21:2a:2a:c2:f5:f2:
         2d:65:56:2f:e8:7e:98:67:09:c8:65:65:e3:18:62:6e:fa:69:
         b6:85:83:1e:68:f2:c4:2a:08:ab:3f:22:2a:68:96:3f:c3:5f:
         7e:04:61:2b:f6:8c:42:de:72:1b:0e:2c:5c:2e:13:ea:5a:9e:
         9e:b0:4c:33
```

Generating a CSR
--------------------------------

```
./myca.sh create-csr
```

Validate the CSR
-----------------------
#### `./myca.sh show-csr foo-server-01.example-domain.com.csr`

```
Certificate Request:
    Data:
        Version: 0 (0x0)
        Subject: C=US, ST=FOO, L=BAR, O=Self Signed OpenSSL CA Cert, OU=Engineering, CN=foo-server-01.example-domain.com
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (2048 bit)
                Modulus:
                    00:ce:bc:e9:87:02:c3:34:5f:cb:21:c4:03:8c:a3:
                    0d:7a:a2:95:ef:f8:c4:95:58:de:28:be:94:18:3a:
                    42:3e:f2:54:1a:68:10:44:c2:a9:33:ee:e5:a0:25:
                    49:4c:72:e7:00:77:32:aa:11:e2:5a:97:3d:69:49:
                    9e:e3:17:5e:13:d6:d0:09:a3:de:b7:80:1e:a4:a8:
                    ad:ab:a5:1d:30:7d:cb:1f:01:2a:70:d0:7b:c2:32:
                    06:b2:dc:3b:2c:03:c9:0f:be:46:bf:aa:f2:a1:b4:
                    d7:75:9f:f6:cc:a2:70:4c:90:53:c7:48:a7:45:71:
                    19:3c:11:c5:6c:b4:e2:ea:fa:7f:40:b8:5d:4e:a2:
                    13:cd:c6:91:eb:5c:e1:ce:6d:4e:29:29:f1:a8:6d:
                    0c:32:fd:ad:d1:3c:18:fa:ec:86:ec:34:52:cc:c4:
                    dd:24:50:e9:f5:49:c2:1b:d2:55:d5:42:58:f8:12:
                    1d:53:d7:5f:ed:9d:b4:ea:74:06:51:a4:f8:3b:d0:
                    9c:a6:da:a2:69:72:de:a5:0b:94:e8:75:16:81:11:
                    38:16:9f:d5:d8:7b:b1:12:b4:21:1b:5d:09:05:d5:
                    75:41:a7:87:4c:55:85:cd:b5:69:77:96:f8:5a:a5:
                    20:5f:72:2e:77:11:2b:61:aa:4b:38:de:b5:ec:88:
                    6b:35
                Exponent: 65537 (0x10001)
        Attributes:
        Requested Extensions:
            X509v3 Basic Constraints:
                CA:FALSE
            X509v3 Key Usage:
                Digital Signature, Non Repudiation, Key Encipherment
            X509v3 Extended Key Usage:
                TLS Web Server Authentication
            X509v3 Subject Alternative Name:
                DNS:*.example-domain.com, DNS:foo-server-01.example-domain.com
    Signature Algorithm: sha256WithRSAEncryption
         09:c9:1d:55:50:6b:77:22:9e:76:e8:a0:d9:37:51:5e:c8:c2:
         7b:79:1b:b7:25:88:f2:f1:9f:a5:52:13:8b:2b:61:ee:e7:e7:
         59:2e:0c:a5:b4:25:6f:fa:e0:ad:03:6b:6b:d1:99:d0:ac:5e:
         f6:4b:08:f3:72:b8:f2:51:dd:c3:14:36:33:cc:01:da:ae:bc:
         8b:2d:89:25:a5:91:e3:53:a8:d0:a8:a9:10:af:fe:82:46:02:
         13:94:c0:8f:db:ce:d2:c0:9d:69:32:e9:2d:8d:b2:b6:39:3f:
         2a:34:40:5c:56:f3:06:7b:70:1c:3d:5d:f7:1c:43:a0:19:37:
         d2:f6:05:61:5c:3d:79:9d:19:aa:a6:24:5f:ff:8c:86:29:13:
         4c:fe:83:7b:ae:33:f8:26:29:80:41:62:7f:07:18:d5:c0:de:
         85:de:6a:22:26:45:55:a5:5d:0b:21:ba:79:f9:aa:f2:9f:cb:
         f2:1d:3d:6e:99:60:aa:00:96:d2:a7:23:a6:9d:06:4e:90:d5:
         be:0b:9b:5f:64:a2:9e:09:14:04:dc:26:b0:49:9e:b0:91:fd:
         8d:e2:40:01:5c:ed:dc:97:12:a1:3b:db:51:59:ee:23:21:4f:
         cf:e4:df:bc:68:6f:63:53:c8:55:ed:bb:ad:f5:65:35:94:f0:
         1b:86:67:8b
```

Sign the CSR
------------

## Drop the CA extensions

```
./myca.sh sign-csr-drop-extensions
```

### Show the certificate and and validate it has no extensions

#### `./myca.sh show-x509 foo-server-01.example-domain.com.crt`

```
Certificate:
    Data:
        Version: 1 (0x0)
        Serial Number: 13453124945170044515 (0xbab319dc23ce9663)
    Signature Algorithm: sha256WithRSAEncryption
        Issuer: C=US, ST=FOO, L=BAR, O=Self Signed OpenSSL CA Cert, OU=Engineering
        Validity
            Not Before: Aug 24 18:43:31 2018 GMT
            Not After : Aug 24 18:43:31 2019 GMT
        Subject: C=US, ST=FOO, L=BAR, O=Self Signed OpenSSL CA Cert, OU=Engineering, CN=foo-server-01.example-domain.com
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (2048 bit)
                Modulus:
                    00:d5:da:86:99:a3:f0:58:7b:ef:f8:9e:71:ec:b6:
                    29:f7:18:30:e2:3d:08:bc:ee:de:0e:57:3b:00:e2:
                    20:66:19:b4:3c:6d:64:c2:31:2f:ff:a3:bb:dd:bf:
                    49:96:22:16:93:bc:92:fb:bd:7b:e1:15:13:56:7e:
                    c4:d2:4c:03:98:9a:78:43:54:02:28:26:65:29:98:
                    ac:f6:78:33:fc:c0:a4:cc:09:d3:00:67:9a:f8:9d:
                    f9:ff:d6:49:d9:9d:b7:72:f8:ad:e9:bf:41:2e:ec:
                    d2:22:e2:45:a3:01:53:9e:a4:d6:f9:84:28:71:e5:
                    81:8c:3c:e7:4d:17:00:6e:57:a1:48:06:5a:d1:c7:
                    bf:65:ae:fb:c1:ea:96:cb:97:ca:c7:02:d4:56:7e:
                    47:4c:e3:85:2f:8e:59:da:a0:be:17:8d:99:d4:54:
                    e3:4b:0f:71:67:39:0b:8f:53:ad:02:fa:39:17:66:
                    37:92:e0:79:b6:64:cf:ee:76:8d:2a:af:13:68:5e:
                    7e:22:a1:21:60:4a:12:33:43:8a:33:3e:91:2c:66:
                    1d:25:25:9a:04:fc:44:5a:9a:d4:a5:99:10:22:d8:
                    20:5e:cb:1a:6d:fa:c5:42:ec:2d:e3:3f:5a:b8:70:
                    b2:cb:0b:c0:64:cf:09:a2:97:c2:a1:ea:62:f5:d5:
                    be:83
                Exponent: 65537 (0x10001)
    Signature Algorithm: sha256WithRSAEncryption
         a2:47:37:54:8d:7f:4a:b3:c5:92:74:67:8f:1c:87:42:fc:39:
         28:cf:74:aa:f3:1a:5d:af:4c:29:8c:b8:91:b8:09:a3:e2:88:
         1b:55:aa:08:52:7b:9e:61:c8:3c:b0:5e:ad:2c:53:70:c0:49:
         1b:89:50:5a:d2:80:64:84:e7:62:1d:a9:d7:51:d3:26:7b:50:
         0e:7f:3a:37:63:0a:f3:71:db:2a:19:5b:b4:04:9b:c1:3b:cf:
         5c:9c:77:e3:9d:eb:59:2b:77:11:76:49:51:a1:24:b4:22:3a:
         37:29:9a:c0:fa:1f:ec:c8:6b:bb:02:c1:f5:2e:a9:ce:19:2c:
         51:16:c7:1d:35:4b:c5:10:09:50:e2:20:51:bc:66:d3:2a:3c:
         81:c9:e6:a0:62:66:8d:14:b2:4e:18:d8:de:2a:c8:8c:94:93:
         b2:28:35:b5:83:df:5b:65:24:65:2c:c7:47:8d:b0:1a:28:e2:
         3e:2b:3a:73:dd:46:d5:7a:1f:82:2f:99:c4:21:46:60:b3:92:
         6e:be:77:3b:1a:ed:43:b5:84:cb:1b:2b:31:ed:bd:c2:ab:cf:
         40:e4:b4:da:9b:cd:80:bf:b4:a2:f7:71:27:e6:ab:45:37:68:
         fd:1b:84:f7:3a:9e:45:a1:4f:27:6f:cf:4b:d6:23:85:92:a8:
         5e:b8:25:89
```

## Sign with extensions
-----------------------

```
./myca.sh sign-csr-keep-extensions
```

### Show the certificate and and validate it has extensions

#### `./myca.sh show-x509 foo-server-01.example-domain.com.crt`

```
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number: 1 (0x1)
    Signature Algorithm: sha256WithRSAEncryption
        Issuer: C=US, ST=FOO, L=BAR, O=Self Signed OpenSSL CA Cert, OU=Engineering
        Validity
            Not Before: Aug 24 18:45:46 2018 GMT
            Not After : Aug 24 18:45:46 2019 GMT
        Subject: C=US, ST=FOO, L=BAR, O=Self Signed OpenSSL CA Cert, CN=foo-server-01.example-domain.com, OU=Engineering
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (2048 bit)
                Modulus:
                    00:cb:77:bd:04:e8:e5:e2:cc:88:ad:92:3b:77:e7:
                    de:16:57:7b:cb:59:f8:ea:3b:fa:ee:d8:b1:ef:8d:
                    d4:6f:7e:e4:fa:16:96:b5:15:cd:e1:02:c1:a8:b3:
                    76:10:22:4a:10:4b:5f:16:5f:c8:e8:41:53:77:ea:
                    f0:c6:0d:50:0e:1e:bc:8b:7f:3f:14:1f:39:88:be:
                    6e:f9:bd:d1:64:5e:c4:3d:c0:c8:96:06:e5:ef:5a:
                    b4:f2:3e:e3:d3:74:bd:22:9d:32:94:ea:66:fa:e3:
                    e8:29:0c:f5:d6:4a:b9:fa:9e:5e:88:ad:8e:6b:ff:
                    3d:2e:42:67:38:c5:24:83:37:40:cf:23:17:92:e1:
                    cd:aa:f9:dc:5e:d1:49:8a:85:be:d1:d5:32:4f:8b:
                    a7:9d:92:be:01:52:75:c4:fb:90:d0:2d:19:5d:7b:
                    13:f9:74:2a:a7:36:8d:8c:66:97:80:0c:c5:09:a1:
                    bf:98:de:4f:26:cf:ec:d9:2a:c9:72:f2:97:0e:39:
                    71:e3:b5:69:57:15:1c:f2:fa:ad:3e:09:45:b2:fa:
                    40:47:34:25:a9:96:d3:03:27:c4:83:06:3c:57:89:
                    b7:23:e9:16:3c:dd:f7:f8:8f:2d:c8:1a:e0:4f:df:
                    8b:d9:d1:db:bc:c9:8d:63:0f:f4:b5:8c:15:ea:31:
                    f6:67
                Exponent: 65537 (0x10001)
        X509v3 extensions:
            X509v3 Basic Constraints:
                CA:FALSE
            Netscape Cert Type:
                SSL Client, S/MIME
            X509v3 Key Usage: critical
                Digital Signature, Key Encipherment
            Netscape Comment:
                Self Signed OpenSSL CA Cert
            X509v3 Subject Key Identifier:
                CE:3C:66:3C:A7:EC:C2:D1:AB:5C:EF:20:78:96:45:99:61:85:67:D7
            X509v3 Authority Key Identifier:
                keyid:59:77:46:2F:25:D2:C1:B8:6C:68:7D:E9:F4:6C:81:D3:FB:20:09:1A

            X509v3 Extended Key Usage:
                TLS Web Server Authentication
            X509v3 Subject Alternative Name:
                DNS:*.example-domain.com, DNS:foo-server-01.example-domain.com
    Signature Algorithm: sha256WithRSAEncryption
         17:a4:b8:19:a0:77:4e:7a:69:55:42:1c:cf:91:26:0a:17:2c:
         48:e7:74:a7:ed:97:27:f5:40:86:83:4e:e7:20:ae:de:44:47:
         5b:07:87:61:a5:9b:6e:ba:9c:dd:4d:61:f0:55:69:48:b4:06:
         ca:3c:15:02:eb:6c:d1:ca:64:27:98:1c:fb:24:34:13:5b:d8:
         9d:1b:97:67:69:1a:9a:52:aa:19:28:e7:b0:8d:9c:5d:b1:42:
         3b:fd:08:3f:b2:47:c6:79:f3:5e:59:a1:54:2f:75:cd:d8:1c:
         80:b8:0a:6a:16:5a:4e:10:db:f3:fb:35:5d:21:d2:9e:b7:b7:
         98:7b:8a:5c:4d:f6:9e:96:d9:62:e7:65:a9:3b:6c:8f:5a:c7:
         93:8e:30:1e:89:b3:d1:cc:0a:fd:69:ee:00:7e:df:a2:8e:af:
         7e:ff:3c:c4:34:99:67:ae:de:f4:f8:94:e0:25:f0:c9:dc:57:
         7c:c1:f5:5d:dd:0b:da:60:8a:84:26:83:87:30:8d:b4:b5:2c:
         d7:5b:20:c6:5c:96:5f:a4:fd:a4:d4:67:f9:f1:74:32:7d:be:
         e7:19:bc:71:48:30:ec:45:fd:1c:25:8b:b1:78:93:38:79:13:
         31:42:7c:50:44:db:6c:81:c0:e3:a6:62:b3:10:a2:92:7f:06:
         da:a8:0a:90
```
