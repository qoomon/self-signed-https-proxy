#!/bin/sh -e
server_domain='localtest.me'
server_port='443'
target_domain="$server_domain"
target_port='8080'

target_address="$target_domain"
# resolve localhost to dockerhost
echo "target_address $target_address"
if [ "$(dig "$target_domain" +short)" == "127.0.0.1" ]; then
  target_address="$(getent hosts host.docker.internal | cut -d' ' -f1)"
  echo "target_address $target_address"
  if [ ! "$target_address" ]; then
    target_address=$(ip -4 route show default | cut -d' ' -f3)
    echo "target_address $target_address"
  fi
fi

if [ ! -e "/etc/nginx/certificates/${server_domain}.key" ]; then
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

openssl genrsa -out "/etc/nginx/certificates/${server_domain}.key" 2048
openssl req -x509 -new -key "/etc/nginx/certificates/${server_domain}.key" \
  -sha256 -nodes -config "$temp_certificate_conf" \
  -out "/etc/nginx/certificates/${server_domain}.crt"

else
  echo "Reusing certificate '${server_domain}.crt' and key '${server_domain}.key'"
fi

# configure nginx
sed -i "s/%server_domain%/${server_domain}/g" /etc/nginx/conf.d/default.conf
sed -i "s/%server_port%/${server_port}/g" /etc/nginx/conf.d/default.conf
sed -i "s/%target_address%/${target_address}/g" /etc/nginx/conf.d/default.conf
sed -i "s/%target_port%/${target_port}/g" /etc/nginx/conf.d/default.conf

# run nginx
echo
echo "https://$server_domain:$server_port -> http://$target_domain:$target_port"
nginx -v
exec nginx -g 'daemon off;'
