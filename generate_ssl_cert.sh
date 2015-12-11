#! /bin/bash


# Script accepts a single argument, the fqdn for the cert
DOMAIN="$1"
if [ -z "$DOMAIN" ]; then
  echo "Usage: $(basename $0) <domain>"
  exit 11
fi

fail_if_error() {
  [ $1 != 0 ] && {
    unset PASSPHRASE
    exit 10
  }
}


# Generate a passphrase
export PASSPHRASE=$(head -c 500 /dev/urandom | tr -dc a-z0-9A-Z | head -c 128; echo)

# Certificate details; replace items in angle brackets with your own info
subj="
C=CN
ST=Shanghai
O=VMware
localityName=Shanghai
commonName=$DOMAIN
organizationalUnitName=IT
emailAddress=rogerluo410@gmail.com
"

echo "Create ssl directory"
sudo mkdir /etc/nginx/ssl
fail_if_error $?
cd /etc/nginx/ssl
fail_if_error $?

echo "Generate the server private key"
# Generate the server private key
openssl genrsa -des3 -out $DOMAIN.key -passout env:PASSPHRASE 2048
fail_if_error $?


echo "Generate the CSR"
# Generate the CSR
openssl req \
    -new \
    -subj "$(echo -n "$subj" | tr "\n" "/" )" \
    -key $DOMAIN.key \
    -out $DOMAIN.csr \
    -passin env:PASSPHRASE
fail_if_error $?
sudo cp $DOMAIN.key $DOMAIN.key.org
fail_if_error $?

echo "Strip the password so we don't have to type it every time we restart Apache"
# Strip the password so we don't have to type it every time we restart Apache
openssl rsa -in $DOMAIN.key.org -out $DOMAIN.key -passin env:PASSPHRASE
fail_if_error $?

echo "Generate the cert (good for 10 years)"
# Generate the cert (good for 10 years)
openssl x509 -req -days 3650 -in $DOMAIN.csr -signkey $DOMAIN.key -out $DOMAIN.crt
fail_if_error $?

sudo rm server.key.org
fail_if_error $?
sudo rm server.csr
fail_if_error $?

sudo chmod 0600 server.key
fail_if_error $?
sudo chmod 0600 server.crt
fail_if_error $?
