#!/bin/sh -e
SERVER_DOMAIN=${SERVER_DOMAIN:-'localtest.me'}
SERVER_PORT=${SERVER_PORT:-'443'}
TARGET_DOMAIN=${TARGET_DOMAIN:-"$SERVER_DOMAIN"}
TARGET_PORT=${TARGET_PORT:-'80'}

target_address="$TARGET_DOMAIN"
# resolve localhost to dockerhost
echo "target_address $target_address"
if [ "$(dig "$TARGET_DOMAIN" +short)" == "127.0.0.1" ]; then
  target_address="$(getent hosts host.docker.internal | cut -d' ' -f1)"
  echo "target_address $target_address"
  if [ ! "$target_address" ]; then
    target_address=$(ip -4 route show default | cut -d' ' -f3)
    echo "target_address $target_address"
  fi
fi

if [ ! -e "/etc/nginx/certificates/${SERVER_DOMAIN}.key" ]; then
  # generate self signed certificate
  mkdir -p '/etc/nginx/certificates/'
  temp_certificate_conf="$(mktemp)"
  cat > "$temp_certificate_conf" << EOL
[req]
distinguished_name = req_distinguished_name
req_extensions = v3_req
prompt = no
[req_distinguished_name]
CN = ${server_domain}
[v3_req]
keyUsage = keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names
[alt_names]
DNS.1 = ${server_domain}
DNS.2 = *.${server_domain}
EOL

openssl genrsa -out "/etc/nginx/certificates/${SERVER_DOMAIN}.key" 2048
openssl req -x509 -new -key "/etc/nginx/certificates/${SERVER_DOMAIN}.key" \
  -sha256 -nodes -config "$temp_certificate_conf" \
  -out "/etc/nginx/certificates/${SERVER_DOMAIN}.crt"

else
  echo "Reusing certificate '${SERVER_DOMAIN}.crt' and key '${SERVER_DOMAIN}.key'"
fi

# configure nginx
sed -i "s/%server_domain%/${SERVER_DOMAIN}/g" /etc/nginx/conf.d/default.conf
sed -i "s/%server_port%/${SERVER_PORT}/g" /etc/nginx/conf.d/default.conf
sed -i "s/%target_address%/${target_address}/g" /etc/nginx/conf.d/default.conf
sed -i "s/%target_port%/${TARGET_PORT}/g" /etc/nginx/conf.d/default.conf

# run nginx
echo
nginx -v
echo
echo "https://$SERVER_DOMAIN:$SERVER_PORT -> http://$TARGET_DOMAIN:$TARGET_PORT"
exec nginx -g 'daemon off;'
