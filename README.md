# localhost-https-proxy

### build
`docker build -t localhost-ssl-proxy .`

### Usage
`docker run -p 443:443 localhost-ssl-proxy`

#### Mount local directory to store and reuse certificate and key
`docker run -v "$PWD":'/etc/nginx/certificates' -p 443:443 localhost-ssl-proxy`
